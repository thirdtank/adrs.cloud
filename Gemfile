source "https://rubygems.org"

gem "brut", path: "/home/appuser/local-gems/brut"
#gem "brut", "0.0.10"

# dotenv manages environment variables for our development and test environments
gem "dotenv", groups: [ :development, :test ]

# Audit our dependencies
gem "bundler-audit", groups: [ :test ]

# This provides higher-level constructs to use for thread-unsafe operations
#gem "concurrent-ruby", require: "concurrent"

# This allows us to make assertions about test setup that are not themselves tests
gem "confidence-check", groups: [ :test ]

# FactoryBot manages test and seed data
gem "factory_bot", groups: [ :test ]

# Faker is used to create realistic data for test and seed data.
gem "faker", groups: [ :test ]

# Omniauth handles user login et. al.
gem "omniauth"

# Login with GitHub. OmniAuth recommends using the version specifier, so we do
gem "omniauth-github", "~> 2.0.0"

# This provides middlwares for Sidekiq and OTel
gem "opentelemetry-instrumentation-sidekiq"

# We use Postgres
gem "pg"

# Allows using Playwright from Ruby.
gem "playwright-ruby-client", groups: [ :test ]

# Sinatra needs a webserver and puma is the best
gem "puma"

# Redcarpet parses and renders Markdown
gem "redcarpet"

# Uses RSpec for testing
gem "rspec", groups: [ :test ]

# We use Sidekiq to process background jobs
gem "sidekiq"

# Allows for diagnosing failing tests
gem "with_clues", groups: [ :test ]
