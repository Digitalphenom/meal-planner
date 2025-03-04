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
  erb :"hero.html", layout: :"layout.html"
end

get '/enter-calories' do
  erb :"enter_calories_page.html", layout: :"layout.html"
end

get '/enter-meals' do
  erb :"enter_meals_page.html", layout: :"layout.html"
end

#◟◅◸◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◅▻◞

post '/enter-calories' do
  if invalid_input?(params[:calories])    
    @add_inline = true
    erb :"enter_calories_page.html", layout: :"layout.html"
  else
    @add_inline = false
    session['user_calories'] = params[:calories]
    redirect 'enter-meals'
  end
end

post '/enter-meals' do
  if invalid_input?(params[:meals])
    @add_inline = true
    erb :"enter_meals_page.html", layout: :"layout.html"
  else
    @add_inline = false
    session['user_meals'] = params[:meals]
    redirect 'choose-macros'
  end
end
