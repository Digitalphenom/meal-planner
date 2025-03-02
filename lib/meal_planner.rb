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
  erb :"subhero.html", layout: :"layout.html"
end