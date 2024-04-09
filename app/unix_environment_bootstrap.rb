require "pathname"
require_relative "brut/project_environment.rb"

PROJECT_ROOT = (Pathname(__dir__) / "..").expand_path
puts "[ #{$0} ] PROJECT_ROOT = '#{PROJECT_ROOT}'"
PROJECT_ENV = ProjectEnvironment.new(ENV["RACK_ENV"])
puts "[ #{$0} ] PROJECT_ENV  = '#{PROJECT_ENV}'"
require "dotenv"
Dotenv.load(PROJECT_ROOT / ".env.#{PROJECT_ENV}", PROJECT_ROOT / ".env.#{PROJECT_ENV}.local")

