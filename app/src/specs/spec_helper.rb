ENV["RACK_ENV"] = "test"
require "bundler"
Bundler.require
require_relative "../../boot"
require "brut/spec_support"

# Because FactoryBot 6.4.6 has a bug where it is not properly
# requiring active support, active supporot must be required first,
# then factory bot.  When 6.4.7 is released, this can be removed. See Gemfile
require "active_support"
require "factory_bot"
require "faker"

Faker::Config.locale = :en
FactoryBot.definition_file_paths = [
  Brut.container.app_src_dir / "specs" / "factories"
]
FactoryBot.define do
  to_create { |instance| instance.save }
end
FactoryBot.find_definitions

SemanticLogger.default_level = ENV.fetch("LOGGER_LEVEL_FOR_TESTS","warn")

RSpec.configure do |config|

  config.around do |example|
    Sequel::Model.db.transaction do
      example.run
      raise Sequel::Rollback
    end
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.filter_run_when_matching :focus

  # Can't find docs on how this path is resolved and I don't use this
  # feature so disabling.
  # config.example_status_persistence_file_path = "spec/examples.txt"

  config.disable_monkey_patching!

  config.warnings = ENV.fetch("RSPEC_WARNINGS","false") == "true"

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  if ENV["RSPEC_PROFILE_EXAMPLES"]
    config.profile_examples = ENV["RSPEC_PROFILE_EXAMPLES"].to_i
  end

  config.include FactoryBot::Syntax::Methods

  config.order = :random

  Kernel.srand config.seed
end
