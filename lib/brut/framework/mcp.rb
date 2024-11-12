require_relative "container"
require_relative "config"
require_relative "../junk_drawer"
require_relative "app"
require "semantic_logger"
require "i18n"
require "zeitwerk"

# Represents the Brut framework and its behavior for the app that requires it.
# Essentially, this handles all default configuration and default setup behavior.
class Brut::Framework::MCP
  def initialize(app_klass:)
    @config    = Brut::Framework::Config.new
    @booted    = false
    @loader    = Zeitwerk::Loader.new
    @app_klass = app_klass
    self.configure!
  end

  def configure!
    @config.configure!

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

    i18n_locales_path = Brut.container.project_root / "app" / "config" / "i18n"
    locales = Dir[i18n_locales_path / "*"].map { |_|
      Pathname(_).basename
    }
    ::I18n.load_path += Dir[i18n_locales_path / "**/*.rb"]
    ::I18n.available_locales = locales.map(&:to_s).map(&:to_sym)

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
    @app = @app_klass.new
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
    require "sinatra/base"
    @sinatra_app = Class.new(Sinatra::Base)
    @sinatra_app.include(Brut::SinatraHelpers)

    @app.class.middleware.each do |(middleware,args,block)|
      @sinatra_app.use(middleware,*args,&block)
    end
    @app.class.before.each do |klass_name|
      klass = klass_name.to_s.split(/::/).reduce(Module) { |mod,part|
        mod.const_get(part)
      }
      before_method = klass.instance_method(:before)
      @sinatra_app.before do
        args = {}

        request_context = Thread.current.thread_variable_get(:request_context)
        app_session = Brut.container.session_class.new(rack_session: session)

        before_method.parameters.each do |(type,name)|
          if name.to_s == "**" || name.to_s == "*"
            raise ArgumentError,"#{method.class}##{method.name} accepts '#{name}' and not keyword args. Define it in your class to accept the keyword arguments your method needs"
          end
          if ![ :key,:keyreq ].include?(type)
            raise ArgumentError,"#{name} is not a keyword arg, but is a #{type}"
          end

          if name == :request_context
            args[name] = request_context
          elsif name == :app_session
            args[name] = app_session
          elsif name == :request
            args[name] = request
          elsif type == :keyreq
            raise ArgumentError,"#{method} argument '#{name}' is required, but it's not available in a before hook"
          else
            # this keyword arg has a default value which will be used
          end
        end

        before_hook = klass.new
        result = before_hook.before(**args)
        case result
        in URI => uri
          redirect to(uri.to_s)
        in Brut::FrontEnd::HttpStatus => http_status
          halt http_status.to_i
        in FalseClass
          halt 500
        in NilClass
          nil
        in TrueClass
          nil
        else
          raise NoMatchingPatternError, "Result from before hook #{klass}'s before method was a #{result.class} (#{result.to_s} as a string), which cannot be used to understand the response to generate. Return nil or true if processing should proceed"
        end
      end
    end
    @app.class.routes.each do |route_block|
      @sinatra_app.instance_eval(&route_block)
    end

    @booted = true
  end
  def sinatra_app = @sinatra_app
  def app = @app


end
