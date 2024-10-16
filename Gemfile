source "https://rubygems.org"

# HOWTO
#
# * "sinatra" is always first
# * All other gems are in alphabetical order
# * Do not use group blocks - specify groups for each gem that should not always be used
# * Precede each gem with a comment explaining what that gem does and why it's here
# * If anything other than the gem name and group is needed, be sure your comment
#   explains why it's there, e.g. specific versions or require: false

# The app runs on Sinatra
gem "sinatra", require: false

# Audit our dependencies
gem "bundler-audit", groups: [ :test ]

# This allows us to make assertions about test setup that are not themselves tests
gem "confidence-check", groups: [ :test ]

# Dotenv manages the UNIX environment for dev and test
gem "dotenv", groups: [:development, :test]

# Factory Bot generates test data
# require: false is there because FactoryBot has a problem with ActiveSupport and so
# it must be loaded first, THEN factory_bot.  If 6.4.7 or later is released,
# this can be removed. See spec_helper.rb
gem "factory_bot", require: false, groups: [ :development, :test ]

# We use faker to generate fake data
gem "faker", groups: [ :development, :test ]

# The i18n gem is used to manage translations
gem "i18n"

# Nokogiri is used to parse HTML in tests
gem "nokogiri", groups: [ :development, :test ]

# Omniauth handles user login et. al.
gem "omniauth"

# Login with GitHub. OmniAuth recommends using the version specifier, so we do
gem "omniauth-github", "~> 2.0.0"

# Not including this generates a warning from some gem. We don't use this.
gem "ostruct"

# We use Postgres
gem "pg"

# Allows using Playwright from Ruby.
gem "playwright-ruby-client", groups: [ :test ]

# Scaffold uses this to parse source files
gem "prism"

# Sinatra needs a webserver and puma is the best
gem "puma"

# Protects against various security issues.
gem "rack-protection"

# Sinatra doesn't include rackup I guess
gem "rackup"

# Redcarpet parses and renders Markdown
gem "redcarpet"

# We use REXML for some basic XML sanitization and attribute construction
gem "rexml"

# Uses RSpec for testing
gem "rspec", groups: [ :test ]

# We log using the semantic_logger gem for more flexibility with what goes in logs and how they work
gem "semantic_logger"

# We use Sequel to access the database
gem "sequel"

# We use Sidekiq to process background jobs
gem "sidekiq"

# We use tilt and Temple for html generation
gem "temple"
gem "tilt"

# Ruby databases for Timezone
gem "tzinfo"
gem "tzinfo-data"

# Allows for diagnosing failing tests
gem "with_clues", groups: [ :test ]

# Zeitwerk handles autoloading of files
gem "zeitwerk"
