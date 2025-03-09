# frozen_string_literal: true
require 'pry-byebug'
require 'sinatra'
require 'erubi'
require 'sinatra/reloader' if development?
require 'rack-livereload'


set :public_folder, File.expand_path('../public', __dir__)
set :views, File.expand_path('../views', __dir__)

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
  erb :"plan.html", layout: :"layout.html"
end

get '/edit-meal:id' do
  'edit meal'
end

#◟◅◸◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◞

post '/enter-calories' do
  if invalid_input?(params[:calories])
    session[:error] = 'Enter a numeric value'
    redirect '/enter-calories'
  else
    session['user_calories'] = params[:calories]
    redirect 'enter-meals'
  end
end

post '/enter-meals' do
  if invalid_input?(params[:meals])
    session[:error] = 'Enter a valid meal count'
    redirect '/enter-meals'
  else
    session['user_meals'] = params[:meals]
    redirect 'choose-macros'
  end
end

post '/choose-macros' do 
  redirect 'build-meal-plan'
end

post '/build-meal-plan/destroy-meal:id' do
  # iterate through meals and reject :id
  # re-serve the meals page
  # redirect '/build-meal-plan'
  "Destroy Meal"
end