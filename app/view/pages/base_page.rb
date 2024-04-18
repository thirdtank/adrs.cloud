require_relative "../view_helpers"
module Pages
  class BasePage < Brut::BasePage
    include ViewHelpers
  end
end
