# frozen_string_literal: true

require 'sinatra'
require 'erubi'
require 'sinatra/reloader'

set :public_folder, File.expand_path('../public', __dir__)
set :views, File.expand_path('../views', __dir__)

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
end

get '/' do
  erb :subhero, layout: :layout
end