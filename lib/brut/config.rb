require_relative "project_environment"
require "pathname"

# Exists to hold configuration for the Brut framework.
# This is a wrapper around a series of calls to Brut.container.store
# but is a class and thus invokable, so that the configuration can
# be controlled.
class Brut::Config

  class DockerPathComponent
    PATH_REGEXP = /\A[a-z0-9]+(-|_)?[a-z0-9]+\z/
    def initialize(string)
      if string.match?(PATH_REGEXP)
        @string = string
      else
        raise ArgumentError.new("Value must be only lower case letters, digits, and may have at most one underscore: '#{string}'")
      end
    end

    def to_str = @string
    def to_s = self.to_str
  end

  class AppId < DockerPathComponent
  end

  class AppOrganizationName < DockerPathComponent
  end

  # Set up all the default Brut configuration. It is not adviable to 
  # run a Brut-powered app without having called this.  By default, this
  # is called from Brut::App.
  def configure!(app_id:, app_organization:)

    app_id           = AppId.new(app_id)
    app_organization = AppOrganizationName.new(app_organization)

    Brut.container do |c|

      c.store(
        "app_id",
        AppId,
        "Id to be used for the app when other processes need it. Should be the name of that app in letters and digits.",
        app_id
      )

      c.store(
        "app_organization",
        AppOrganizationName,
        "Id for the organization that owns or manages the app. This is used when the app must be referenced in systems with a hierarchy such as Docker or GitHub",
        app_organization
      )

      c.store_ensured_path(
        "tmp_dir",
        "Temporary directory where ephemeral files can do"
      ) do |project_root|
        project_root / "tmp"
      end

      c.store(
        "project_env",
        ProjectEnvironment,
        "The environment of the running app, e.g. dev/test/prod",
        ProjectEnvironment.new(ENV["RACK_ENV"]) )

      c.store_ensured_path(
        "log_dir",
        "Path where log files may be written"
      ) do |project_root|
        project_root / "logs"
      end

      c.store_ensured_path(
        "public_root_dir",
        "Path to the root of all public files"
      ) do |project_root|
        project_root / "app" / "public"
      end

      c.store_ensured_path(
        "css_bundle_output_dir",
        "Path where bundled CSS is written for use in web pages"
      ) do |public_root_dir|
        public_root_dir / "css"
      end

      c.store_ensured_path(
        "js_bundle_output_dir",
        "Path where bundled JS is written for use in web pages"
      ) do |public_root_dir|
        public_root_dir / "js"
      end

      c.store(
        "log_level",
        String,
        "Log level to control how much logging is happening"
      ) do
        ENV["LOG_LEVEL"] || "debug"
      end

      c.store(
        "sequel_db_handle",
        String,
        "URL connection string for the primary database"
      ) do
        Sequel.connect(ENV.fetch("DATABASE_URL"))
      end

      c.store_ensured_path(
        "app_src_dir",
        "Path to root of where all the app's source files are"
      ) do |project_root|
        project_root / "app" / "src"
      end

      c.store_ensured_path(
        "app_specs_dir",
        "Path to root of where all the app's specs/tests are"
      ) do |app_src_dir|
        app_src_dir / "specs"
      end

      c.store_required_path(
        "front_end_src_dir",
        "Path to the root of the front end layer for the app"
      ) do |app_src_dir|
        app_src_dir / "front_end"
      end

      c.store_required_path(
        "components_src_dir",
        "Path to where components classes and templates are stored"
      ) do |front_end_src_dir|
        front_end_src_dir / "components"
      end

      c.store_required_path(
        "forms_src_dir",
        "Path to where form classes are stored"
      ) do |front_end_src_dir|
        front_end_src_dir / "forms"
      end

      c.store_required_path(
        "handlers_src_dir",
        "Path to where handlers are stored"
      ) do |front_end_src_dir|
        front_end_src_dir / "handlers"
      end

      c.store_required_path(
        "svgs_src_dir",
        "Path to where svgs are stored"
      ) do |front_end_src_dir|
        front_end_src_dir / "svgs"
      end

      c.store_required_path(
        "pages_src_dir",
        "Path to where page classes and templates are stored"
      ) do |front_end_src_dir|
        front_end_src_dir / "pages"
      end

      c.store_required_path(
        "layouts_src_dir",
        "Path to where layout classes and templates are stored"
      ) do |front_end_src_dir|
        front_end_src_dir / "layouts"
      end

      c.store_required_path(
        "back_end_src_dir",
        "Path to the root of the back end layer for the app"
      ) do |app_src_dir|
        app_src_dir / "back_end"
      end

      c.store_ensured_path(
        "migrations_dir",
        "Path to the DB migrations",
      ) do |back_end_src_dir|
        back_end_src_dir / "db" / "migrations"
      end

      c.store_ensured_path(
        "db_seeds_dir",
        "Path to the seed data for the DB",
      ) do |back_end_src_dir|
        back_end_src_dir / "db" / "seed"
      end

      c.store_ensured_path(
        "config_dir",
        "Path to where configuration files are stores"
      ) do |project_root|
        project_root / "app" / "config"
      end

      c.store(
        "asset_metadata_file",
        Pathname,
        "Path to the asset metadata file, used to manage hashed asset names"
      ) do |config_dir|
        config_dir / "asset_metadata.json"
      end


      c.store(
        "layout_locator",
        "Brut::FrontEnd::Component::TemplateLocator",
        "Object to use to locate templates for layouts"
      ) do |layouts_src_dir|
        Brut::FrontEnd::Component::TemplateLocator.new(path: layouts_src_dir,
                                                       extension: "html.erb")
      end

      c.store(
        "page_locator",
        "Brut::FrontEnd::Component::TemplateLocator",
        "Object to use to locate templates for pages"
      ) do |pages_src_dir|
        Brut::FrontEnd::Component::TemplateLocator.new(path: pages_src_dir,
                                                       extension: "html.erb")
      end

      c.store(
        "component_locator",
        "Brut::FrontEnd::Component::TemplateLocator",
        "Object to use to locate templates for components"
      ) do |components_src_dir|
        Brut::FrontEnd::Component::TemplateLocator.new(path: components_src_dir,
                                                       extension: "html.erb")
      end

      c.store(
        "svg_locator",
        "Brut::FrontEnd::Component::TemplateLocator",
        "Object to use to locate SVGs"
      ) do |svgs_src_dir|
        Brut::FrontEnd::Component::TemplateLocator.new(path: svgs_src_dir,
                                                       extension: "svg")
      end

      c.store(
        "asset_path_resolver",
        "Brut::FrontEnd::Component::AssetPathResolver",
        "Object to use to resolve logical asset paths to actual asset paths"
      ) do |asset_metadata_file|
        Brut::FrontEnd::Component::AssetPathResolver.new(metadata_file: asset_metadata_file)
      end

      c.store(
        "routing",
        "Brut::FrontEnd::Routing",
        "Routing for all registered routes of this app",
        Brut::FrontEnd::Routing.new
      )

      c.store(
        "session_class",
        Class,
        "Class to use when wrapping the Rack session",
        Brut::FrontEnd::Session,
        allow_app_override: true,
      )

      c.store(
        "flash_class",
        Class,
        "Class to use to represent the Flash",
        Brut::FrontEnd::Flash,
        allow_app_override: true,
      )

    end
  end
end
