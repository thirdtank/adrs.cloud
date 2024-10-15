module Support
  module E2E
    module Login
      def login(page:,account:)
        page.goto("/")
        button = page.locator("form[action='/auth/developer'] button")
        button.click

        field = page.locator("input[name=email]")
        field.fill(account.email)
        button = page.locator("form button")
        button.click
        expect(page).to be_page_for(AdrsPage)
      end
    end
  end
end

