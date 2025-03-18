# frozen_string_literal: true

require 'pry-byebug'
require 'sinatra'
require 'erubi'
require 'sinatra/reloader' if development?
require 'rack-livereload'
require 'httparty'
require 'json'
require 'dotenv/load'

URL = 'https://trackapi.nutritionix.com/v2/natural/nutrients'
MACRO_ID = [208, 203, 205, 204].freeze
MACRO = %i[protein carb fat total_calories].freeze
CALORIES_PER_GRAM = { protein: 4, carb: 4, fat: 9 }.freeze
MACRO_PRESET = {
  Endurance: %w[20 50 30],
  Strength: %w[40 30 30],
  Weight_Loss: %w[50 25 25]
}.freeze

configure do
  use Rack::LiveReload
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
  set :public_folder, File.expand_path('../public', __dir__)
  set :views, File.expand_path('../views', __dir__)
  set :api_key, ENV['API_KEY']
  set :api_id, ENV['API_ID']
end

helpers do
  def add_inline
    @add_inline ? 'background-color: #FFB5B5' : ''
  end

  def meals_count_arr
    session['user_one'][:total_meals].keys
  end

  def access_meal_values
    meal_food_items = session['user_one'][:total_meals][@meal_id].keys
    meal_item_macros = session['user_one'][:total_meals][@meal_id].values

    meal_food_items.each.with_index do |food_item, idx|
      
      protein = meal_item_macros[idx][:protein]
      carb = meal_item_macros[idx][:carb]
      fat = meal_item_macros[idx][:fat]
      total_calories = meal_item_macros[idx][:total_calories]

      yield(food_item, total_calories, protein, carb, fat) if block_given?
    end
  end

  def meals?
    !session['user_one'][:total_meals][@meal_id].empty?
  end
end

# ◟◅◸◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◞

def invalid_input?(input)
  if env['REQUEST_PATH'] == '/enter-meals'
    input.to_i > 12 || input.match?(/\D/) || input.to_i.zero?
  else
    input.match?(/\D/) || input.to_i.zero?
  end
end

def capture_meal_values
  @macros = session[:user_one][:presets][:macros].split(',').map(&:to_i)
  @meals = session[:user_one][:presets][:meals].to_i
  @total_calories = session[:user_one][:presets][:calories].to_i
end

def retrieve_calories_per_gram
  result = @macros.map.with_index do |macro, idx|
    (macro.to_f / 100) * @total_calories / CALORIES_PER_GRAM[MACRO[idx]]
  end
  @protein, @carb, @fat = result.map { |ratio| (ratio / @meals).floor(2) }
end

def retrieve_calories_per_meal
  @calories_per_meal = @total_calories / @meals
end

def initialize_macros
  capture_meal_values
  retrieve_calories_per_meal
  retrieve_calories_per_gram
end

def capture_calc_values
  arr = [@protein, @carb, @fat, @calories_per_meal]

  arr.each.with_index do |macro, idx|
    session[:user_one][:calc][MACRO[idx]] = macro
  end
end

def initialize_meal_count
  session['user_one'][:total_meals] = {}
  @meals.times do |idx|
    session['user_one'][:total_meals][idx + 1] = {}
  end
end

def extract_macros
  nutrients_arr = @nutrients.map(&:values)

  result = MACRO_ID.each_with_object([]) do |id, result|
    result << nutrients_arr.select do |sub_arr|
      next if sub_arr.first != id
      sub_arr.first
    end
  end.flatten(1)
  result.map { |sub_arr| sub_arr.last.floor(2) }
end


def query_nutritionix
  body = { query: "#{@food_portion} #{@food_choice}" }
  headers = {
    'x-app-id' => settings.api_id, 'x-app-key' => settings.api_key,
    'Content-Type' => 'application/json'
  }

  response = HTTParty.post(URL, headers: headers, body: body.to_json)
  @nutrients = response['foods'].first['full_nutrients']
  extract_macros
end

def insert_chosen_food_macros
  macro = %i[total_calories protein carb fat]

  session['user_one'][:total_meals].each do |key, hsh|
    next unless key == @meal_id

    query_nutritionix.each.with_index do |macro_value, idx|
      hsh[@food_choice] = {} unless hsh[@food_choice]
      hsh[@food_choice][macro[idx]] = macro_value
    end
  end
end

# ◟◅◸◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◞

get '/' do
  session[:user_one] = {}
  session[:user_one][:presets] = {}
  session[:user_one][:calc] = {}
  erb :"home.html", layout: :"layout.html"
end

get '/enter-calories' do
  erb :"calories.html", layout: :"layout.html"
end

get '/enter-meals' do
  erb :"meals.html", layout: :"layout.html"
end

get '/choose-macros' do
  erb :"macros.html", layout: :"layout.html"
end

get '/build-meal-plan' do
  initialize_macros
  capture_calc_values
  initialize_meal_count
  erb :"plan.html", layout: :"layout.html"
end

get '/build-meal-plan/edit-meal/:id' do
  @total_protein, @total_carb, @total_fat, @calories_per_meal =
    MACRO.map { |macro| session[:user_one][:calc][macro] }

  @meal_id = params[:id].to_i
  session['user_one'][:total_meals][@meal_id]
  erb :"edit-meal.html", layout: :"layout.html"
end

get '/build-meal-plan/edit-meal/:id/add-meal' do
  @yaml = YAML.load_file('food_list.yml')
  @meal_id = params[:id].to_i
  erb :"add_meal.html", layout: :"layout.html"
end

# ◟◅◸◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◞

post '/build-meal-plan/edit-meal/:id' do
  @meal_id = params[:id].to_i
  @food_choice = params[:food_choice]
  @food_portion = params[:food_portion]
  insert_chosen_food_macros

  result = MACRO.map { |macro| session[:user_one][:calc][macro] }
  @total_protein, @total_carb, @total_fat, @calories_per_meal = result

  erb :"edit-meal.html", layout: :"layout.html"
end

post '/enter-calories' do
  if invalid_input?(params[:calories])
    session[:error] = 'Enter a numeric value'
    redirect '/enter-calories'
  else
    session[:user_one][:presets][:calories] = params[:calories]
    redirect 'enter-meals'
  end
end

post '/enter-meals' do
  if invalid_input?(params[:meals])
    session[:error] = 'Enter a valid meal count'
    redirect '/enter-meals'
  else
    session[:user_one][:presets][:meals] = params[:meals]
    redirect 'choose-macros'
  end
end

post '/choose-macros' do
  session[:user_one][:presets][:macros] = params[:macros]
  redirect 'build-meal-plan'
end

post '/build-meal-plan/destroy-meal:id' do
  # iterate through meals and reject :id
  # re-serve the meals page
  # redirect '/build-meal-plan'
  'Destroy Meal'
end
