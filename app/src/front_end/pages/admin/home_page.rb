class Admin::HomePage < Admin::BasePage

  attr_reader :new_account_form, :account_search_form, :flash
  def initialize(authenticated_account:, new_account_form:nil,flash:)
    super(authenticated_account:)
    @new_account_form      = new_account_form || Admin::NewAccountForm.new
    @account_search_form   = Admin::AccountSearchForm.new
    @flash                 = flash
  end

  def page_template
    if flash.notice?
      aside(
        role: "status",
        class: "ba bc-blue-600 bg-blue-900 blue-300 tc pa-3 br-3 w-50 mh-auto mb-3"
      ) do
        t(flash.notice)
      end
    end
    if flash.alert?
      aside(
        role: "status",
        class: "ba bc-red-600 bg-red-900 red-300 tc pa-3 br-3 w-50 mh-auto mb-3"
      ) do
        t(flash.alert)
      end
    end
    section(class:"mh-auto w-two-thirds") do
      h1 { "Admin" }
      div(class: "flex justify-between gap-3") do
        brut_form(class: "flex-grow-1") do
          FormTag(
            for: new_account_form.class,
            class:"flex flex-column gap-2 shadow-2-ns mh-auto pa-4-ns br-1 bg-white-ish-ns"
          ) do
            render(
              TextFieldComponent.new(
              label: "Email address",
              form: new_account_form,
              input_name: "email",
              placeholder: "e.g. pat@example.com",
              autofocus: true)
            )
            div(class: "mt-2 flex justify-center") do
              render(
                ButtonComponent.new(
                  size: "normal",
                  color: "orange",
                  label: "Allow User Access",
                  confirm: "This GitHub user will be able to create ADRs",
                  icon: "key-icon")
              )
            end
          end
        end
        brut_form(class: "flex-grow-1") do
          FormTag(for: Admin::AccountsPage,
                       class:"flex flex-column gap-2 shadow-2-ns mh-auto pa-4-ns br-1 bg-white-ish-ns") do
            render TextFieldComponent.new(
              label: "Email Address or Fragment",
              form: account_search_form,
              input_name: "search_string",
              placeholder: "e.g. davetron5000",
              autofocus: true)
            div(class: "mt-2 flex justify-center") do
              render(
                ButtonComponent.new(size: "normal", variant: :search, color: "blue", label: "Find Accounts", icon: "search-icon")
              )
            end
          end
        end
      end
    end
    render(ConfirmationDialogComponent.new)
  end
end
