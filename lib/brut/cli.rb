module Brut
  module CLI

    def self.app(app_klass, project_root:)
      global_options = {}
      option_parser = app_klass.option_parser
      get_help = false
      option_parser.on("-h", "--help", "Get help") do
        show_global_help(option_parser,app_klass)
        exit 0
      end
      rest = option_parser.order!(into:global_options)
      command_name = rest[0]
      command_klass = app_klass.commands.detect { |c| c.name_matches?(command_name) }
      if !command_klass
        $stderr.puts "No such command '#{command_name}'"
        exit 1
      end
      command_options = {}
      command_option_parser = command_klass.option_parser
      command_help = false
      command_option_parser.on("-h", "--help", "Get help on this command") do
        show_command_help(option_parser,command_option_parser,command_klass)
        exit 0
      end
      args = command_option_parser.order!(rest[1..-1],into:command_options)
      cli_app = app_klass.new(global_options:)
      cmd = command_klass.new(command_options:,args:)
      result = cli_app.execute!(cmd, project_root:)
      if result.message
        if !result.ok?
          puts "error: #{result.message}"
          puts
          show_command_help(option_parser,command_option_parser,command_klass)
        else
          puts result.message
        end
      end
      result.to_i
    end

    def self.show_global_help(option_parser,app_klass)
      option_parser.banner =  option_parser.banner % {
        app: $0,
        global_options: option_parser.top.list.length == 0 ? "" : "[global options]",
      }
      puts option_parser.banner
      puts
      puts "   #{app_klass.description}"
      puts
      puts "GLOBAL OPTIONS"
      puts
      option_parser.summarize do |line|
        puts line
      end
      if app_klass.commands.any?
        puts
        puts "COMMANDS"
        puts
        max_length = app_klass.commands.map { |_| _.command_name.to_s.length }.max
        printf_string = "    %-#{max_length}s - %s\n"
        app_klass.commands.sort_by(&:command_name).each  do |command|
          printf printf_string, command.command_name, command.description
        end
      end
      puts
    end

    def self.show_command_help(option_parser,command_option_parser,command_klass)
      banner = command_option_parser.banner % {
        app: $0,
        global_options: option_parser.top.list.length == 0 ? "" : "[global options]",
        command_options: command_option_parser.top.list.length == 0 ? "" : "[command options]",
        args: command_klass.args,
      }
      command_option_parser.banner = "Usage: #{banner}"
      puts command_option_parser.banner
      puts
      puts "    " + command_klass.description
      puts
      puts "GLOBAL OPTIONS"
      option_parser.summarize do |line|
        puts line
      end
      puts
      puts "COMMAND OPTIONS"
      command_option_parser.summarize do |line|
        puts line
      end
    end
    autoload(:App, "brut/cli/app")
    autoload(:Command, "brut/cli/command")
    autoload(:Error, "brut/cli/error")
    autoload(:ExecutionResults, "brut/cli/execution_results")
  end
end
