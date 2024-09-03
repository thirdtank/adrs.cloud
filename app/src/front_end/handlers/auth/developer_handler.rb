module Auth
  class DeveloperHandler < AppHandler
    def handle!
      DeveloperAuthPage.new
    end
  end
end
