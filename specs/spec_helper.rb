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

SemanticLogger.default_level = ENV.fetch("LOGGER_LEVEL_FOR_TESTS","warn")
Brut::FactoryBot.new.setup!

class TestServer
  def self.instance
    @instance ||= TestServer.new(bin_dir: Brut.container.project_root / "bin")
  end

  def initialize(bin_dir:)
    @bin_dir = bin_dir
    @pid     = nil
  end

  def start
    if !@pid.nil?
      puts "already started server"
      return
    end
    Bundler.with_unbundled_env do
      puts "Starting test server"
      @pid = Process.spawn(
        "#{@bin_dir}/test-server",
        pgroup: true # We want this in its own process group, so we can 
                     # more reliably kill it later on
      )
      puts "Spawned '#{@pid}'"
    end
    if is_port_open?("0.0.0.0",6503)
      puts "server started"
    else
      raise "Problem: server never started"
    end
  end

  def stop
    if @pid.nil?
      puts "Server already stopped"
      return
    end
    puts "killing server nicely"
    Process.kill("-TERM",@pid) # The '-' is to kill the process group, not just the pid
    begin
      Timeout.timeout(4) do
        Process.wait(@pid)
      end
    rescue Timeout::Error
      binding.irb
      puts "Server did not die after 4 seconds. Trying harder"
      Process.kill("-KILL",@pid)
    end
    @pid = nil
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
    if metadata[:described_class].to_s =~ /[a-z0-9]Page$/ ||
       metadata[:page] == true
      metadata[:page] = true
    end
    if metadata[:described_class].to_s =~ /[a-z0-9]Handler$/
      metadata[:handler] = true
    end
    relative_path = Pathname(metadata[:absolute_file_path]).relative_path_from(Brut.container.app_specs_dir)
    if relative_path.split[0].to_s == "e2e"
      metadata[:e2e] = true
    end
  end
  config.include ConfidenceCheck::ForRSpec
  config.include WithClues::Method
  config.include Brut::SpecSupport::GeneralSupport
  config.include Brut::SpecSupport::ComponentSupport, component: true
  config.include Brut::SpecSupport::HandlerSupport, handler: true
  config.include Playwright::Test::Matchers, e2e: true
  config.around do |example|

    request_context   = Thread.current.thread_variable_get(:request_context)
    is_component      = example.metadata[:component]
    is_page           = example.metadata[:page]
    is_e2e            = example.metadata[:e2e]
    e2e_timeout       = example.metadata[:e2e_timeout] || 5_000

    if is_component
      session = {
        "session_id" => "test-session-id",
        "csrf" => "test-csrf-token"
      }
      env = {
        "rack.session" => session
      }
      app_session = Brut.container.session_class.new(rack_session: session)
      request_context = Brut::RequestContext.new(
        env: env,
        session: app_session,
        flash: empty_flash,
        body: nil,
        xhr: false,
      )
      Thread.current.thread_variable_set(:request_context, request_context)
      example.example_group.let(:request_context) { request_context }
      example.example_group.let(:component_name) { described_class.component_name }
    end
    if is_page
      example.example_group.let(:page_name) { described_class.page_name }
    end

    if is_e2e
      Sidekiq::Testing.disable! do
        Sidekiq.redis do |redis|
          redis.flushall
        end

        TestServer.instance.start
        Playwright.create(playwright_cli_executable_path: "./node_modules/.bin/playwright") do |playwright|
          playwright.chromium.launch(headless: true) do |browser|
            context_options = {
              baseURL: "http://0.0.0.0:6503/",
            }
            if ENV["E2E_RECORD_VIDEOS"]
              context_options[:record_video_dir] =  Brut.container.project_root / "videos"
            end
            browser_context = browser.new_context(**context_options)
            browser_context.default_timeout = (ENV["E2E_TIMEOUT_MS"] || e2e_timeout).to_i
            example.example_group.let(:page) { browser_context.new_page }
            example.run
            browser_context.close
            browser.close
          end
        end
      end
    else
      Sidekiq::Worker.clear_all
      Sequel::Model.db.transaction do
        # XXX:
        create(:entitlement_default, internal_name: "basic")
        example.run
        raise Sequel::Rollback
      end
    end
    if is_component
      Thread.current.thread_variable_set(:request_context,request_context)
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
