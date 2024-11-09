module Brut
  # This is the namespace for Brut-provided CLI Apps.  This is not to be confused with Brut::CLIApp, which is the 
  # basis for any brut-powered CLI app.
  module CLI

    def self.app(app_klass, project_root:)
      out      = Brut::CLI::Output.new(io: $stdout,prefix: "[ #{$0} ] ")
      err      = Brut::CLI::Output.new(io: $stderr,prefix: "[ #{$0} ] ")
      executor = Brut::CLI::Executor.new(out:,err:)

      global_options = {}

      option_parser = app_klass.option_parser

      option_parser.on("-h", "--help", "Get help") do
        show_global_help(option_parser:,app_klass:,out:)
        exit 0
      end

      rest = option_parser.order!(into:global_options)

      command_name = rest[0] || app_klass.default_command

      if !command_name
        err.puts "error: #{$0} requires a command"
        err.puts_no_prefix "\n"
        show_global_help(option_parser:,app_klass:,out:)
        exit 1
      end

      if command_name == "help"
        if rest[1]
          command_klass = app_klass.commands.detect { |c| c.name_matches?(rest[1]) }
          if command_klass
            command_option_parser = command_klass.option_parser
            show_command_help(option_parser:,command_option_parser:,command_klass:,out:)
            exit 0
          else
            err.puts "error: No such command '#{command_name}'"
            err.puts_no_prefix "\n"
          end
        end
        show_global_help(option_parser:,app_klass:,out:)
        exit 0
      end

      command_klass = app_klass.commands.detect { |c| c.name_matches?(command_name) }

      if !command_klass
        show_global_help(option_parser:,app_klass:,out:)
        exit 1
      end

      command_options = {}

      command_option_parser = command_klass.option_parser

      command_option_parser.on("-h", "--help", "Get help on this command") do
        show_command_help(option_parser:,command_option_parser:,command_klass:,out:)
        exit 0
      end

      command_argv = rest[1..-1] || []
      args = command_option_parser.parse!(command_argv,into:command_options)

      global_options = Brut::CLI::Options.new(global_options)
      cli_app = app_klass.new(global_options:, out:, err:, executor:)
      cmd = command_klass.new(command_options:Brut::CLI::Options.new(command_options),global_options:, args:, out:, err:, executor:)

      result = cli_app.execute!(cmd, project_root:)

      if result.message
        if !result.ok?
          err.puts "error: #{result.message}"
          err.puts
          show_command_help(option_parser:,command_option_parser:,command_klass:,out:)
        else
          out.puts result.message
        end
      end
      result.to_i
    end

    def self.show_global_help(option_parser:,app_klass:,out:)
      option_parser.banner =  option_parser.banner % {
        app: $0,
        global_options: option_parser.top.list.length == 0 ? "" : "[global options]",
      }
      out.puts_no_prefix option_parser.banner
      out.puts_no_prefix
      out.puts_no_prefix "   #{app_klass.description}"
      out.puts_no_prefix
      out.puts_no_prefix "GLOBAL OPTIONS"
      out.puts_no_prefix
      option_parser.summarize do |line|
        out.puts_no_prefix line
      end
      if app_klass.commands.any?
        out.puts_no_prefix
        out.puts_no_prefix "COMMANDS"
        out.puts_no_prefix
        max_length = app_klass.commands.map { |_| _.command_name.to_s.length }.max
        printf_string = "    %-#{max_length}s - %s%s\n"
        app_klass.commands.sort_by(&:command_name).each  do |command|
          default_message = if command.name_matches?(app_klass.default_command)
                              " (default)"
                            else
                              ""
                            end

          description = if command.description && command.description.kind_of?(Proc)
                          command.description.()
                        else
                          command.description
                        end
          printf printf_string, command.command_name, command.description, default_message
        end
      end
      out.puts_no_prefix
    end

    def self.show_command_help(option_parser:,command_option_parser:,command_klass:,out:)
      banner = command_option_parser.banner % {
        app: $0,
        global_options: option_parser.top.list.length == 0 ? "" : "[global options]",
        command_options: command_option_parser.top.list.length == 0 ? "" : "[command options]",
        args: command_klass.args,
      }
      command_option_parser.banner = "Usage: #{banner}"
      out.puts_no_prefix command_option_parser.banner
      out.puts_no_prefix
      out.puts_no_prefix "    " + command_klass.description
      out.puts_no_prefix
      if command_klass.detailed_description
        out.puts_no_prefix "    " + command_klass.detailed_description.strip
        out.puts_no_prefix
      end
      out.puts_no_prefix "GLOBAL OPTIONS"
      option_parser.summarize do |line|
        out.puts_no_prefix line
      end
      if command_option_parser.top.list.length > 0
        out.puts_no_prefix
        out.puts_no_prefix "COMMAND OPTIONS"
        command_option_parser.summarize do |line|
          out.puts_no_prefix line
        end
      end
    end
    autoload(:App, "brut/cli/app")
    autoload(:Command, "brut/cli/command")
    autoload(:Error, "brut/cli/error")
    autoload(:SystemExecError, "brut/cli/error")
    autoload(:ExecutionResults, "brut/cli/execution_results")
    autoload(:Options, "brut/cli/options")
    autoload(:Output, "brut/cli/output")
    autoload(:Executor, "brut/cli/executor")
    module Apps
      autoload(:DB,"brut/cli/apps/db")
      autoload(:DB,"brut/cli/apps/test")
      autoload(:DB,"brut/cli/apps/build_assets")
      autoload(:DB,"brut/cli/apps/scaffold")
    end
  end
end
require_relative "i18n"
