require_relative "config"
require_relative "junk_drawer"
require "semantic_logger"
require "dotenv"
require "open3"
require "i18n"

# A class representing the Brut-powered app that is being built.
# Unlike Brut::Config, this sets up more dynamic and app-specific stuff,
# including any third party gems that need configuration.
class Brut::App
  def initialize
    @config = Brut::Config.new
    @booted = false
  end

  def id           = raise SubclassMustImplement
  def organization = raise SubclassMustImplement


  # Starts up the internals of Brut and that app so that it can receive requests from
  # the web server.  This *can* make network connections to establish connectivity
  # to external resources.
  def boot!
    if @booted
      raise "already booted!"
    end
    self.configure_only!
    Kernel.at_exit do
      Brut.container.sequel_db_handle.disconnect
    end

    Sequel::Model.db = Brut.container.sequel_db_handle
    @booted = true
  end

  # Used to establish all configuration options
  # for Brut and the app.  This call will not make network connections
  # or start any services, however due to the dynamic nature of some of the
  # configured objects in the container, requesting access to a configured
  # object may make network connections.
  def configure_only!
    @config.configure!(
      app_id: self.id,
      app_organization: self.organization,
    )


    project_root = Brut.container.project_root
    project_env = Brut.container.project_env

    Dotenv.load(project_root / ".env.#{project_env.to_s}",
                project_root / ".env.#{project_env.to_s}.local")

    log_dir = Brut.container.log_dir
    FileUtils.mkdir_p log_dir
    SemanticLogger.default_level = Brut.container.log_level
    SemanticLogger.add_appender(file_name: (log_dir / "development.log").to_s)
    SemanticLogger.add_appender(io: $stdout, formatter: :color)
    SemanticLogger["Brut"].info("Logging set up")

    ::I18n.load_path += Dir[Brut.container.project_root / "app" / "config" / "i18n" / "**/*.rb"]

  end

end
