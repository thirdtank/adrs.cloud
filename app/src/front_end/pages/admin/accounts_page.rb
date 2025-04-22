class Admin::AccountsPage < Admin::BasePage

  attr_reader :search_string, :matching_accounts
  def initialize(authenticated_account:, search_string:)
    super(authenticated_account:)
    @matching_accounts = DB::Account.where(Sequel.like(:email,"%#{search_string}%")).to_a
    @search_string = search_string
  end

  def edit_account_path(account)
    Admin::AccountsByExternalIdPage.routing(external_id: account.external_id)
  end
  def page_template
    section(class: "mh-auto w-two-thirds") do
      h1 { "Accounts" }
      if matching_accounts.any?
        table(class: "collapse w-100") do
          thead do
            tr do
              th(class:"bb bc-gray-200 tl fw-bold f-3 pa-2") do
                "Email Address"
              end
              th(class:"bb bc-gray-200 tl fw-bold f-3 pa-2") do
                span(class: "sr-only") { "Actions" }
              end
            end
          end
          tbody do
            matching_accounts.each do |account|
              tr do
                td(class: "bb br bc-gray-500 pa-2") do
                  code { account.email }
                end
                td(class: "bb bc-gray-500 pa-2") do
                  a(
                    class:"blue-300",
                    href: edit_account_path(account).to_s
                  ) do
                    "Edit"
                  end
                end
              end
            end
          end
        end
      else
        p(class: "p i") do
          "Nothing Matched #{search_string}"
        end
      end
      a(href: Admin::HomePage.routing.to_s, class: "db mt-3") do
        raw(safe("&larr; Back"))
      end
    end
  end
end
