source "https://rubygems.org"

# The app runs on Sinatra
gem "sinatra", require: false

# We need the namespace contrib
gem "sinatra-contrib"

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

# We log using the semantic_logger gem for more flexibility
# with what goes in logs and how they work
gem "semantic_logger"
