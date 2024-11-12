class Bootstrap

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

    ConfiguredBootstrap.new(mcp: Brut::Framework::MCP.new(app_klass: ::App))
  end

  def bootstrap!
    self.configure_only!.bootstrap!
  end

  class ConfiguredBootstrap
    def initialize(mcp:)
      @mcp = mcp
    end
    def bootstrap!
      @mcp.boot!
      Bootstraped.new(rack_app: @mcp.sinatra_app.new)
    end
    def app = @mcp.app
  end

  class Bootstraped
    attr_reader :rack_app
    def initialize(rack_app:)
      @rack_app = rack_app
    end
  end


end
