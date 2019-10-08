require 'simplecov'
SimpleCov.start do
  add_filter '/rails/'
  add_filter '/spec/'
end

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Codecov
  ]
end

ENV['RAILS_ENV'] = 'test'

# prepare ENV for rails
require 'rails'
ENV['RAILS_ROOT'] = File.expand_path(
  "../rails/rails-#{Rails::VERSION::STRING}",
  __FILE__
)

if RUBY_VERSION >= '2.6.0'
  if Rails.version < '5'
    class ActionController::TestResponse < ActionDispatch::TestResponse
      def recycle!
        # HACK: avoid MonitorMixin double-initialize error:
        @mon_mutex_owner_object_id = nil
        @mon_mutex = nil
        initialize
      end
    end
  else
    puts "Monkeypatch for ActionController::TestResponse not needed for rails #{Rails.version}"
  end
end

# ensure testing application is in place
unless File.exist?(ENV['RAILS_ROOT'])
  puts 'Please run bundle exec rake setup before running the specs.'
  exit
end

# load up activeadmin and activeadmin-xls
require 'active_record'
require 'active_admin'
require 'devise'
require 'activeadmin-xls'
ActiveAdmin.application.load_paths = [ENV['RAILS_ROOT'] + '/app/admin']

# start up rails
require ENV['RAILS_ROOT'] + '/config/environment'

# and finally,here's rspec
require 'rspec/rails'

# Disabling authentication in specs so that we don't have to worry about
# it allover the place
ActiveAdmin.application.authentication_method = false
ActiveAdmin.application.current_user_method = false
