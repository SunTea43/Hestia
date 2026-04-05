ENV["RAILS_ENV"] ||= "test"

# Set default APARTMENT_TENANTS for tests
# Tests that need specific tenants can override this in setup
ENV["APARTMENT_TENANTS"] ||= "public,test"

require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Don't load fixtures by default - individual test classes can opt-in
    # fixtures :all

    # Add more helper methods to be used by all tests here...
    include Devise::Test::IntegrationHelpers
  end
end
