# frozen_string_literal: true

ENV['SINATRA_ENV'] = 'test'
ENV['RACK_ENV'] = 'test'
ENV['APP_ENV'] = 'test'

require_relative '../config/environment'

require_all './lib'
require 'factory_bot'

require 'rack/test'
require 'database_cleaner/active_record'

DatabaseCleaner.strategy = :truncation

if ActiveRecord::Base.connection.migration_context.needs_migration?
  raise 'Migrations are pending. Run `rake db:migrate SINATRA_ENV=test` to resolve the issue.'
end

ActiveRecord::Base.logger = nil

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.include Rack::Test::Methods
  config.order = 'default'

  config.include FactoryBot::Syntax::Methods
  config.before(:suite) do
    FactoryBot.find_definitions
  end

  config.before do
    DatabaseCleaner.clean
  end

  config.after do
    DatabaseCleaner.clean
  end
end

def app
  Rack::Builder.parse_file('config.ru').first
end
