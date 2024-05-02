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

# Convention is as follows:
#
# * singluar thing is a class, the base class of others  being used, e.g. the base page is called Brut::Page
#   (e.g. and not Brut::Pages::Base).
module Brut
  autoload(:Renderable, "brut/renderable")
  autoload(:Component, "brut/component")
  autoload(:Components, "brut/component")
  autoload(:Page, "brut/page")
  autoload(:SinatraHelpers, "brut/sinatra_helpers")
  autoload(:FormSubmission, "brut/form_submission")
  autoload(:Action, "brut/action")
  autoload(:Actions, "brut/action")
end
