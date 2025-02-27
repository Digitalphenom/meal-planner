ENV['RACK_ENV'] = 'test'

require 'minitest/reporters'
require 'minitest/autorun'
require 'rack/test'

Minitest::Reporters.use!

require_relative '../lib/meal_planner'

class MealPlannerTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_home
    get '/'
    assert_equal 200, last_response.status
  end

end