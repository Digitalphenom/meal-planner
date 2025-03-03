# frozen_string_literal: true

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

get '/' do
  @next_page = '/enter-calories'
  @button_text = 'Get Started'
  erb :"subhero.html", layout: :"layout.html"
end

get '/enter-calories' do
  @button_text = 'Get Started'
  @placeholder_name = 'Enter your calories'
  erb :"layout.html"
end

get '/enter-meals' do
  @placeholder_name = 'Enter your meal count'
  erb :"layout.html"
end

post '/enter-calories' do
  @input_name = 'calories'
  session['user_calories'] = params[@input_name]
  redirect 'enter-meals'
end

post '/enter-meals' do
  @input_name = 'meals'
  session['user_meals'] = params[@input_name]
  redirect 'choose-macros'
end
