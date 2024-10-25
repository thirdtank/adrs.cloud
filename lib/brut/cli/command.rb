require "optparse"
class Brut::CLI::Command
  include Brut::CLI::ExecutionResults

  def self.description(new_description=nil)
    if new_description.nil?
      return @description.to_s
    else
      @description = new_description
    end
  end
  def self.args(new_args=nil)
    if new_args.nil?
      return @args.to_s
    else
      @args = new_args
    end
  end
  def self.command_name = RichString.new(self.name.split(/::/).last).underscorized
  def self.name_matches?(string)
    self.command_name == string || self.command_name.to_s.gsub(/_/,"-") == string
  end
  def self.opts
    self.option_parser
  end
  def self.option_parser
    @option_parser ||= OptionParser.new do |opts|
      opts.banner = "%{app} %{global_options} #{command_name} %{command_options} %{args}"
    end
  end

  def initialize(command_options:,args:)
    @command_options = command_options || {}
    @args            = args            || []
  end

  def delegate_to_command(command_klass)
    command = command_klass.new(command_options: @command_options, args: @args)
    as_execution_result(command.execute)
  end

  def execute
    raise SubclassMustImplement
  end

  def before_execute
  end

  def handle_bootstrap_exception(ex)
    raise ex
  end

  def bootstrap!(project_root:)
    require "bundler"
    Bundler.require(:default, ENV["RACK_ENV"].to_sym)
    require "#{project_root}/app/boot"
  end
end
