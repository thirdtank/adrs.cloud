class Bootstrap

  class ConfiguredBootstrap
    def initialize(framework:)
      @framework = framework
    end
    def bootstrap!
      @framework.boot!
      require "route_config"
      Bootstraped.new(rack_app: AdrApp.new)
    end
  end

  class Bootstraped
    attr_reader :rack_app
    def initialize(rack_app:)
      @rack_app = rack_app
    end
  end

  def configure_only!
    require "bundler"

    Bundler.require(:default, ENV.fetch("RACK_ENV").to_sym)
    $LOAD_PATH << File.join(__dir__,"..","lib") # Only needed since Brut is not a gem

    require "brut"
    require "pathname"

    Brut.container.store_required_path(
      "project_root",
      "Root of the entire project's source code checkout",
      (Pathname(__dir__) / "..").expand_path)


    $: << File.join(Brut.container.project_root,"app","src")

    require "app"

    ConfiguredBootstrap.new(framework: Brut::Framework.new(app: ::App.new))
  end

  def bootstrap!
    self.configure_only!.bootstrap!
  end

end
