require_relative "config"
require "semantic_logger"
require "dotenv"

# A class representing the Brut-powered app that is being built.
# Unlike Brut::Config, this sets up more dynamic and app-specific stuff,
# including any third party gems that need configuration.
class Brut::App
  def initialize
    @config = Brut::Config.new
  end

  # Set up everything that the app needs to do what it needs to do.
  def start! # XXX: this is just doing setup and should be safe to call w/out assuming a web server will start
    self.configure_only!
    Kernel.at_exit do
      Brut.container.sequel_db_handle.disconnect
    end

    Sequel::Model.db = Brut.container.sequel_db_handle

  end

  def configure_only! # XXX: This should not be needed
    @config.configure!
    project_root = Brut.container.project_root
    project_env = Brut.container.project_env
    Dotenv.load(project_root / ".env.#{project_env.to_s}", project_root / ".env.#{project_env.to_s}.local")

    log_dir = Brut.container.log_dir
    FileUtils.mkdir_p log_dir
    SemanticLogger.default_level = Brut.container.log_level
    SemanticLogger.add_appender(file_name: (log_dir / "development.log").to_s)
    SemanticLogger.add_appender(io: $stdout, formatter: :color)
    SemanticLogger["Brut"].info("Logging set up")

  end
end
