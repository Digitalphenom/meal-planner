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
  @next_page = '/enter calories'
  erb :"subhero.html", layout: :"layout.html"
end

get '/enter calories' do
  erb :"layout.html"
end

get '/enter meals' do
  @next_page = '/enter meals'
  erb :"layout.html"
end

post '/enter calories' do
  session['user'] = params['calories']
  redirect 'enter calories'
end
