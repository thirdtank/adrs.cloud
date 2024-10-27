require "optparse"
require_relative "../junk_drawer"
class Brut::CLI::App
  include Brut::CLI::ExecutionResults
  def self.commands
    self.constants.map { |name|
      self.const_get(name)
    }.select { |constant|
      constant.kind_of?(Class) && constant.ancestors.include?(Brut::CLI::Command) && constant.instance_methods.include?(:execute)
    }
  end
  def self.description(new_description=nil)
    if new_description.nil?
      return @description.to_s
    else
      @description = new_description
    end
  end
  def self.default_command(new_command_name=nil)
    if new_command_name.nil?
      return @default_command || "help"
    else
      @default_command = new_command_name.nil? ? nil : new_command_name.to_s
    end
  end
  def self.opts
    self.option_parser
  end
  def self.option_parser
    @option_parser ||= OptionParser.new do |opts|
      opts.banner = "%{app} %{global_options} commands [command options] [args]"
    end
  end

  def initialize(global_options:,out:,err:,executor:)
    @global_options = global_options
    @out            = out
    @err            = err
    @executor       = executor
  end

  def before_execute
  end

  def execute!(command,project_root:)
    before_execute
    command.set_env_if_needed
    command.before_execute
    bootstrap_result = begin
                         as_execution_result(command.bootstrap!(project_root:))
                       rescue => ex
                         as_execution_result(command.handle_bootstrap_exception(ex))
                       end
    if bootstrap_result.stop?
      return bootstrap_result
    end
    as_execution_result(command.execute)
  rescue Brut::CLI::Error => ex
    abort_execution(ex.message)
  end

private

  def out = @out
  def err = @err
  def puts(...)
    warn("Your CLI apps should use out and err to produce terminal output, not puts", uplevel: 1)
    Kernel.puts(...)
  end

end
