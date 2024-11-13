class Brut::FrontEnd::RouteHooks::Reload < Brut::FrontEnd::RouteHook
  def before
    if Brut.container.auto_reload_classes?
      begin
        Brut.container.zeitwerk_loader.reload
        Brut.container.routing.reload
        Brut.container.asset_path_resolver.reload
        ::I18n.reload!
      rescue => ex
        SemanticLogger[self.class].warn("Reload failed - your browser may not show you the latest code: #{ex.message}")
      end
    end
    continue
  end
end
