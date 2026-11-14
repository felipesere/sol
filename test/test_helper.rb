ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module AuthHelpers
  def use_auth(env)
    @previous_auth = Rails.configuration.x.auth
    Rails.configuration.x.auth = AuthConfig.new(env)
  end

  def teardown
    Rails.configuration.x.auth = @previous_auth if @previous_auth
    super
  end

  def sign_in_as(name)
    use_auth("HOUSEHOLD_USERS" => name)
    post session_path, params: { name: name }
  end
end

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all
  end
end

class ActionDispatch::IntegrationTest
  include AuthHelpers
end
