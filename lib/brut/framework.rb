require_relative "container"
require_relative "config"
require_relative "junk_drawer"
require_relative "app"
require "semantic_logger"
require "i18n"
require "zeitwerk"

# Represents the Brut framework and its behavior for the app that requires it.
# Essentially, this handles all default configuration and default setup behavior.
class Brut::Framework
  def initialize(app:)
    @config = Brut::Config.new
    @booted = false
    @loader = Zeitwerk::Loader.new
    @app    = app
    self.configure!
  end

  def configure!
    @config.configure!(
      app_id: @app.id,
      app_organization: @app.organization,
    )

    project_root = Brut.container.project_root
    project_env  = Brut.container.project_env

    SemanticLogger.default_level = Brut.container.log_level
    semantic_logger_appenders = Brut.container.semantic_logger_appenders
    if semantic_logger_appenders.kind_of?(Hash)
      semantic_logger_appenders = [ semantic_logger_appenders ]
    end
    if semantic_logger_appenders.length == 0
      raise "No loggers are set up - something is wrong"
    end
    semantic_logger_appenders.each do |appender|
      SemanticLogger.add_appender(**appender)
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
    @app.configure!
  end

  # Starts up the internals of Brut and that app so that it can receive requests from
  # the web server.  This *can* make network connections to establish connectivity
  # to external resources.
  def boot!
    if @booted
      raise "already booted!"
    end
    if Brut.container.debug_zeitwerk?
      @loader.log!
    end
    Kernel.at_exit do
      begin
      Brut.container.sequel_db_handle.disconnect
      rescue Sequel::DatabaseConnectionError
        SemanticLogger["Sequel::Database"].info "Not connected to database, so not disconnecting"
      end
    end

    Sequel::Database.extension :pg_array
    Sequel::Database.extension :brut_instrumentation

    sequel_db = Brut.container.sequel_db_handle
    sequel_db.logger = SemanticLogger["Sequel::Database"]

    Sequel::Model.db = sequel_db


    Sequel::Model.plugin :find_bang
    Sequel::Model.plugin :created_at

    if !Brut.container.external_id_prefix.nil?
      Sequel::Model.plugin :external_id, global_prefix: Brut.container.external_id_prefix
    end
    if Brut.container.eager_load_classes?
      SemanticLogger["Brut"].info("Eagerly loading app's classes")
      @loader.eager_load
    else
      SemanticLogger["Brut"].info("Lazily loading app's classes")
    end
    Brut.container.instrumentation.subscribe do |event:,start:,stop:,exception:|
      SemanticLogger["Instrumentation"].info("#{event.category}/#{event.subcategory}/#{event.name}: #{start}/#{stop} = #{stop-start}: #{exception&.message} (#{event.details})")
    end
    @app.boot!
    @booted = true
  end


end
