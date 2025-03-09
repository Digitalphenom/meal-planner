# frozen_string_literal: true
require 'pry-byebug'
require 'sinatra'
require 'erubi'
require 'sinatra/reloader' if development?
require 'rack-livereload'


set :public_folder, File.expand_path('../public', __dir__)
set :views, File.expand_path('../views', __dir__)
MACRO = [:protein, :carb, :fat]
CALORIES_PER_GRAM = {protein: 4, carb: 4, fat: 9 }

configure do
  use Rack::LiveReload
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
end


helpers do 
  def add_inline
    @add_inline ? 'background-color: #FFB5B5' : ''
  end

  def macros
    { Endurance: %w[20 50 30],
      Strength: %w[40 30 30],
      Weight_Loss: %w[50 25 25] 
    }
  end
end

def invalid_input?(input)
  if env["REQUEST_PATH"] == '/enter-meals'  
    input.to_i > 12 || input.match?(/\D/) || input.to_i.zero?
  else
    input.match?(/\D/) || input.to_i.zero?
  end
end

#◟◅◸◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◞

get '/' do
  session[:user_one] = {}
  erb :"home.html", layout: :"layout.html"
end
{ "user_one"=>{:calories => 100, }}
get '/enter-calories' do
  erb :"calories.html", layout: :"layout.html"
end

get '/enter-meals' do
  erb :"meals.html", layout: :"layout.html"
end

get '/choose-macros' do
  erb :"macros.html", layout: :"layout.html"
end

def extract_macros
  @macros = session[:user_one][:macros].split(',').map(&:to_i)
  @meals = session[:user_one][:meals].to_i
  @total_calories = session[:user_one][:calories].to_i
end

def retrieve_calories_per_gram(macros, calories)
  @protein, @carb, @fat = macros.map.with_index do |macro, idx|
    (macro.to_f / 100) * calories / CALORIES_PER_GRAM[MACRO[idx]]
  end.map { |ratio| (ratio / @meals).floor(2) }
end

def retrieve_calories_per_meal
  @calories_per_meal = @total_calories / @meals
end

def initialize_macros
  extract_macros
  retrieve_calories_per_meal
  retrieve_calories_per_gram(@macros, @total_calories)
end

get '/build-meal-plan' do
  initialize_macros
  erb :"plan.html", layout: :"layout.html"
end

get 'build-meal-plan/edit-meal:id' do
  
  'edit meal'
end

#◟◅◸◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◞

post '/enter-calories' do
  if invalid_input?(params[:calories])
    session[:error] = 'Enter a numeric value'
    redirect '/enter-calories'
  else
    session[:user_one][:calories] = params[:calories]
    redirect 'enter-meals'
  end
end

post '/enter-meals' do
  if invalid_input?(params[:meals])
    session[:error] = 'Enter a valid meal count'
    redirect '/enter-meals'
  else
    session[:user_one][:meals] = params[:meals]
    redirect 'choose-macros'
  end
end

post '/choose-macros' do 
  
  session[:user_one][:macros] = params[:macros]
  redirect 'build-meal-plan'
end

post '/build-meal-plan/destroy-meal:id' do
  # iterate through meals and reject :id
  # re-serve the meals page
  # redirect '/build-meal-plan'
  "Destroy Meal"
end