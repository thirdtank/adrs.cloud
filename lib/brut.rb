module Brut
end
require_relative "brut/project_environment"
require "pathname"

PROJECT_ROOT = (Pathname(__dir__) / "..").expand_path
puts "[ #{$0} ] PROJECT_ROOT = '#{PROJECT_ROOT}'"
PROJECT_ENV = ProjectEnvironment.new(ENV["RACK_ENV"])
puts "[ #{$0} ] PROJECT_ENV  = '#{PROJECT_ENV}'"
require "dotenv"
Dotenv.load(PROJECT_ROOT / ".env.#{PROJECT_ENV}", PROJECT_ROOT / ".env.#{PROJECT_ENV}.local")

require_relative "brut/base_component"
require_relative "brut/input"
require_relative "brut/input/textfield"
require_relative "brut/input/textarea"
require_relative "brut/base_page"
require_relative "brut/sinatra_helpers"
