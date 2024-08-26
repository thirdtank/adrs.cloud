source "https://rubygems.org"

# The app runs on Sinatra
gem "sinatra", require: false

# We need the namespace contrib
gem "sinatra-contrib", require: false

# Sinatra doesn't include rackup I guess
gem "rackup"

# Sinatra needs a webserver and puma is the best
gem "puma"

# Audit our dependencies
gem "bundler-audit"

# We use Sequel to access the database
gem "sequel"

# We use Postgres
gem "pg"

# Dotenv manages the UNIX environment for dev and test
gem "dotenv", groups: [:development, :test]

# Omniauth handles user login et. al.
gem "omniauth"
gem "omniauth-github", "~> 2.0.0"

gem "rack-protection"

# We use REXML for some basic XML sanitization
gem "rexml"

# Redcarpet parses and renders Markdown
gem "redcarpet"

# Uses RSpec for testing
gem "rspec"

# We use tilt and Temple for html generation
gem "tilt"
gem "temple"

# The i18n gem is used to manage translations
gem "i18n"

# Scaffold uses this to parse source files
gem "prism"

# Factory Bot generates test data
# require: false is there because FactoryBot has a problem with ActiveSupport and so
# it must be loaded first, THEN factory_bot.  If 6.4.7 or later is released,
# this can be removed. See spec_helper.rb
gem "factory_bot", require: false

# We use faker to generate fake data
gem "faker"

# Nokogiri is used to parse HTML in tests
gem "nokogiri"

# We log using the semantic_logger gem for more flexibility
# with what goes in logs and how they work
gem "semantic_logger"
