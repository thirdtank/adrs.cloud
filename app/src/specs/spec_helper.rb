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
require "nokogiri"

require "socket"
require "timeout"
require "playwright"
require "playwright/test"

require_relative "support"

Faker::Config.locale = :en
FactoryBot.definition_file_paths = [
  Brut.container.app_src_dir / "specs" / "factories"
]
FactoryBot.define do
  to_create { |instance| instance.save }
end
FactoryBot.find_definitions

SemanticLogger.default_level = ENV.fetch("LOGGER_LEVEL_FOR_TESTS","warn")

class TestServer
  def self.instance
    @instance ||= TestServer.new(bin_dir: Brut.container.project_root / "bin",
                                 tmp_dir: Brut.container.tmp_dir)
  end

  def initialize(bin_dir:,tmp_dir:)
    @bin_dir = bin_dir
    @tmp_dir = tmp_dir
    @thread  = nil
  end

  def start
    if !@thread.nil?
      puts "already started server"
      return
    end
    @thread = Thread.new do
      puts "server starting"
      system "#{@bin_dir}/build-and-run"
    end
    if is_port_open?("0.0.0.0",6502)
      puts "server started"
    else
      raise "Problem: server never started"
    end
  end

  def stop
    puts "server already stopped"
    return if @thread.nil?
    pid = File.read(@tmp_dir / "pidfile").chomp
    puts "killing server nicely"
    system "kill #{pid}"
    result = @thread.join(2)
    if result.nil?
      puts "server did not die after 2 seconds. Trying -9"
      system "kill -9 #{pid}"
    else
      puts "server stopped it seems"
    end
    @thread = nil
  end

private

  def is_port_open?(ip, port)
    begin
      Timeout::timeout(5) do
        loop do
          begin
            s = TCPSocket.new(ip, port)
            s.close
            return true
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
            sleep(0.1)
          end
        end
      rescue Timeout::Error
      end
      false
    end
  end
end
RSpec.configure do |config|

  config.define_derived_metadata do |metadata|
    if metadata[:described_class].to_s =~ /[a-z0-9]Component$/ ||
       metadata[:described_class].to_s =~ /[a-z0-9]Page$/ ||
       metadata[:page] == true
      metadata[:component] = true
    end
    if metadata[:described_class].to_s =~ /[a-z0-9]Handler$/
      metadata[:handler] = true
    end
    relative_path = Pathname(metadata[:absolute_file_path]).relative_path_from(Brut.container.app_specs_dir)
    if relative_path.split[0].to_s == "e2e"
      metadata[:e2e] = true
    end
  end
  config.include Brut::SpecSupport::GeneralSupport
  config.include Brut::SpecSupport::ComponentSupport, component: true
  config.include Brut::SpecSupport::HandlerSupport, handler: true
  config.include Playwright::Test::Matchers, e2e: true
  config.around do |example|

    rendering_context = Thread.current[:rendering_context]
    is_component      = example.metadata[:component]
    is_e2e            = example.metadata[:e2e]

    if is_component
      Thread.current[:rendering_context] = {
        csrf_token: "test-csrf-token"
      }
    end
    if is_e2e
      TestServer.instance.start
      Playwright.create(playwright_cli_executable_path: "./node_modules/.bin/playwright") do |playwright|
        playwright.chromium.launch(headless: true) do |browser|
          example.example_group.let(:browser) { browser }
          example.run
        end
      end
    else
      Sequel::Model.db.transaction do
        # XXX:
        create(:entitlement_default, internal_name: "basic")
        example.run
        raise Sequel::Rollback
      end
    end
    if is_component
      Thread.current[:rendering_context] = rendering_context
    end
  end

  config.after(:suite) do
    TestServer.instance.stop
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
