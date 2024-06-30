require_relative "project_environment"
require "pathname"
class Brut::Config
  def initialize
  end
  def configure!
    Brut.container do |c|

      c.store_required_path(
        "project_root",
        "Root of the entire project's source code checkout",
        (Pathname(__dir__) / ".." / "..").expand_path)

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
        "css_bundle_output_dir",
        "Path where bundled CSS is written for use in web pages"
      ) do |project_root|
        project_root / "app" / "public" / "css"
      end

      c.store_ensured_path(
        "js_bundle_output_dir",
        "Path where bundled JS is written for use in web pages"
      ) do |project_root|
        project_root / "app" / "public" / "js"
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
        Sequel.connect(ENV.fetch(
          "DATABASE_URL"))
      end

      c.store_required_path(
        "front_end_src_dir",
        "Path to the root of the front end layer for the app"
      ) do |project_root|
        project_root / "app" / "src" / "front_end"
      end

      c.store_required_path(
        "components_src_dir",
        "Path to where components classes and templates are stored"
      ) do |front_end_src_dir|
        front_end_src_dir / "components"
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
    end
  end
end
