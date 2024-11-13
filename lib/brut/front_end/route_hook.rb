module Brut::FrontEnd
  class RouteHook
    include Brut::FrontEnd::HandlingResults
    # Return this to continue the hook
    def continue = true
  end

  module RouteHooks
    autoload(:LocaleDetection, "brut/front_end/route_hooks/locale_detection")
    autoload(:SetupRequestContext, "brut/front_end/route_hooks/setup_request_context")
    autoload(:AgeFlash, "brut/front_end/route_hooks/age_flash")
    autoload(:CSP, "brut/front_end/route_hooks/csp")
  end
end
