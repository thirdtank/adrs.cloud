require_relative "config"
require_relative "junk_drawer"
require "semantic_logger"
require "i18n"
require "zeitwerk"

# This is only needed in dev/test, but it's needed ASAP, so
# we'll check if we are production when there is an issue
begin
require "dotenv"
rescue LoadError => ex
  if ENV["RACK_ENV"] != "production"
    raise ex
  end
end


# A class representing the Brut-powered app that is being built.
# Unlike Brut::Config, this sets up more dynamic and app-specific stuff,
# including any third party gems that need configuration.
class Brut::App
  def initialize
    @config = Brut::Config.new
    @booted = false
    @loader = Zeitwerk::Loader.new
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

    Brut.container.sequel_db_handle.logger = SemanticLogger["Sequel::Database"]
    Sequel::Model.db = Brut.container.sequel_db_handle
    Sequel::Model.db.extension :pg_array
    Sequel::Model.plugin :external_id, global_prefix: "ad"
    Sequel::Model.plugin :find_bang
    Sequel::Model.plugin :created_at
    if Brut.container.eager_load_classes?
      SemanticLogger["Brut"].info("Eagerly loading app's classes")
      @loader.eager_load
    else
      SemanticLogger["Brut"].info("Lazily loading app's classes")
    end
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

    if !project_env.production?
      Dotenv.load(project_root / ".env.#{project_env.to_s}",
                  project_root / ".env.#{project_env.to_s}.local")
    end

    log_dir               = Brut.container.log_dir
    log_file_name         = Brut.container.log_file_name
    log_to_stdout_options = Brut.container.log_to_stdout_options

    FileUtils.mkdir_p log_dir
    SemanticLogger.default_level = Brut.container.log_level
    if log_file_name
      SemanticLogger.add_appender(file_name: log_file_name.to_s)
    else
      puts "Not logging to a file"
    end
    if log_to_stdout_options
      SemanticLogger.add_appender(**log_to_stdout_options.merge(io: $stdout))
    else
      puts "Not logging to stdout"
    end
    SemanticLogger["Brut"].info("Logging set up")

    ::I18n.load_path += Dir[Brut.container.project_root / "app" / "config" / "i18n" / "**/*.rb"]

    Brut.container.store(
      "zeitwerk_loader",
      @loader.class,
      "Zeitwerk Loader configured for this app",
      @loader
    )

    Dir[Brut.container.front_end_src_dir / "*"].each do |dir|
      if Pathname(dir).directory?
        @loader.push_dir(dir)
      end
    end
    Dir[Brut.container.back_end_src_dir / "*"].each do |dir|
      if Pathname(dir).directory?
        @loader.push_dir(dir)
      end
    end
    @loader.ignore(Brut.container.migrations_dir)
    @loader.inflector.inflect(
      "db" => "DB"
    )
    if Brut.container.auto_reload_classes?
      SemanticLogger["Brut"].info("Auto-reloaded configured")
      @loader.enable_reloading
    else
      SemanticLogger["Brut"].info("Classes will not be auto-reloaded")
    end
    @loader.setup
    #@loader.log!
  end

end
