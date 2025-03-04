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

def valid_input?(input)
  if env["REQUEST_PATH"] == '/enter-meals'  
    !input.to_i.zero? && input.to_i.size < 13
  else
    !input.to_i.zero?
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
  if valid_input?(params['calories'])
    @add_inline = false
    session['user_calories'] = params['calories']
    redirect 'enter-meals'
  else
    @placeholder_name = 'Enter a numeric value'
    @add_inline = true
    erb :"enter_calories_page.html", layout: :"layout.html"
  end
end

post '/enter-meals' do
  @input_name = 'meals'
  if valid_input?(params[@input_name])
    @add_inline = false
    session['user_meals'] = params[@input_name]
    redirect 'choose-macros'
  else
    @placeholder_name = 'Enter a numeric value between 1-12'
    @add_inline = true
    erb :"layout.html"
  end
end
