require_relative "brut/container"
require_relative "brut/app"

# Convention is as follows:
#
# * singluar thing is a class, the base class of others  being used, e.g. the base page is called Brut::Page
#   (e.g. and not Brut::Pages::Base).
module Brut
  module FrontEnd
    autoload(:Component, "brut/front_end/component")
    autoload(:Components, "brut/front_end/component")
    autoload(:Page, "brut/front_end/page")
    autoload(:Flash, "brut/front_end/flash")
    autoload(:Form, "brut/front_end/form")
    autoload(:Handler, "brut/front_end/handler")
    autoload(:Routing, "brut/front_end/routing")
    autoload(:HttpMethod, "brut/front_end/http_method")
    autoload(:HttpStatus, "brut/front_end/http_status")
  end
  module BackEnd
    autoload(:Result, "brut/back_end/result")
    autoload(:Action, "brut/back_end/action")
    autoload(:Actions, "brut/back_end/action")
    autoload(:Validators, "brut/back_end/validator")
    autoload(:Error, "brut/back_end/error")
    autoload(:Errors, "brut/back_end/error")
  end
  autoload(:I18n, "brut/i18n")
  autoload(:SinatraHelpers, "brut/sinatra_helpers")
end
