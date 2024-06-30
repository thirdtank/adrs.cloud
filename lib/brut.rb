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
    autoload(:Form, "brut/front_end/form")
  end
  module BackEnd
    autoload(:Action, "brut/back_end/action")
    autoload(:Actions, "brut/back_end/action")
  end
  autoload(:SinatraHelpers, "brut/sinatra_helpers")
end
