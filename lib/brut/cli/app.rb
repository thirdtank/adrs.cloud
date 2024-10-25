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
  def self.opts
    self.option_parser
  end
  def self.option_parser
    @option_parser ||= OptionParser.new do |opts|
      opts.banner = "%{app} %{global_options} commands [command options] [args]"
    end
  end

  def initialize(global_options:)
    @global_options = global_options
  end

  def before_execute
  end

  def execute!(command,project_root:)
    before_execute
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
end
