require 'sinatra'
require 'erubi'
require 'sinatra/reloader'

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
end

get '/' do
  'Welcome To Tailored Meals!'
end

