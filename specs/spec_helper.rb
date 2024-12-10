ENV["RACK_ENV"] = "test"
require_relative "../app/bootstrap"
Bootstrap.new.bootstrap!

require "brut/spec_support"

require "nokogiri"

require "socket"
require "timeout"
require "playwright"
require "playwright/test"
require "confidence_check/for_rspec"
require "with_clues"
require "sidekiq/testing"

require_relative "support"

RSpec.configure do |config|
  rspec_setup = Brut::SpecSupport::RSpecSetup.new(rspec_config: config)
  rspec_setup.setup!(
    inside_db_transaction: ->() {
      FactoryBot.create(:entitlement_default, internal_name: "basic")
    }
  )

  config.include ConfidenceCheck::ForRSpec
  config.include WithClues::Method
  config.include FactoryBot::Syntax::Methods

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

  config.order = :random

  Kernel.srand config.seed
end
