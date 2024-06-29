module Brut
end
require_relative "brut/project_environment"
require "pathname"
require "semantic_logger"

PROJECT_ROOT = (Pathname(__dir__) / "..").expand_path
puts "[ #{$0} ] PROJECT_ROOT = '#{PROJECT_ROOT}'"
PROJECT_ENV = ProjectEnvironment.new(ENV["RACK_ENV"])
puts "[ #{$0} ] PROJECT_ENV  = '#{PROJECT_ENV}'"
require "dotenv"
Dotenv.load(PROJECT_ROOT / ".env.#{PROJECT_ENV}", PROJECT_ROOT / ".env.#{PROJECT_ENV}.local")

LOG_DIR = PROJECT_ROOT / "logs"
FileUtils.mkdir_p LOG_DIR
SemanticLogger.default_level = ENV["LOG_LEVEL"] || "debug"
SemanticLogger.add_appender(file_name: (LOG_DIR / "development.log").to_s)
SemanticLogger.add_appender(io: $stdout, formatter: :color)
SemanticLogger["Brut"].info("Logging set up")
# Convention is as follows:
#
# * singluar thing is a class, the base class of others  being used, e.g. the base page is called Brut::Page
#   (e.g. and not Brut::Pages::Base).
module Brut
  autoload(:Component, "brut/component")
  autoload(:Components, "brut/component")
  autoload(:Page, "brut/page")
  autoload(:SinatraHelpers, "brut/sinatra_helpers")
  autoload(:Form, "brut/form")
  autoload(:Action, "brut/action")
  autoload(:Actions, "brut/action")
end
