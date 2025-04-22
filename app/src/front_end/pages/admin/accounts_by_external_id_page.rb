class Admin::AccountsByExternalIdPage < Admin::BasePage
  attr_reader :account, :form, :flash
  def initialize(authenticated_account:, external_id:, form: nil, flash:)
    super(authenticated_account:)
    @account = DB::Account.find!(external_id:)
    @form = form || Admin::AccountEntitlementsWithExternalIdForm.new(params: {
      max_non_rejected_adrs: @account.entitlement.max_non_rejected_adrs,
    })
    @flash = flash
    if @form.constraint_violations?
      flash.alert = :entitlements_cannot_be_saved
    end
  end

  def effective(method)
    override = @account.entitlement.send(method)
    if override.nil?
      @account.entitlement.entitlement_default.send(method)
    else
      override
    end
  end

  def page_template
    if flash.notice?
      aside(
        role: "status",
      class: "ba bc-blue-600 bg-blue-900 blue-300 tc pa-3 br-3 w-50 mh-auto mb-3"
      ) do
        t(page: flash.notice).to_s
      end
    end
    if flash.alert?
      aside(
        role:"status",
        class: "ba bc-red-600 bg-red-900 red-300 tc pa-3 br-3 w-50 mh-auto mb-3"
      ) do
        t(page: flash.alert).to_s
      end
    end
    section(class:"mh-auto w-two-thirds") do
      nav(class: "w-100 flex items-center pa-3") do
        a(href: Admin::HomePage.routing.to_s) do
          raw(safe("&larr; #{t(:back)}"))
        end
      end
      h1 {
        code { account.email } 
      }
      h2 {
        "Entitlements - #{account.entitlement.entitlement_default.internal_name}"
      }
      brut_form do
        form_tag(
          action: form.class.routing(external_id: account.external_id).to_s,
          method: :post
        ) do
          table(class: "collapse w-100") do
            thead do
              tr do
                th(class:"bb br tl f-3 pa-2") {
                  "Entitlement"
                }
                th(class:"bb br tl f-3 pa-2") {
                  account.entitlement.entitlement_default.internal_name
                }
                th(class:"bb br tl f-3 pa-2") {
                  "Account-specific Value"
                }
                th(class:"bb    tr f-3 pa-2 bg-gray-800 fw-bold") {
                  "Effective Value"
                }
              end
            end
            tbody do
              tr do
                th(class:"bb br tl pa-2") {
                  label(for:"max_non_rejected_adrs") {
                    "Max Non-Rejected ADRs"
                  }
                }
                td(class:"bb br tl pa-2") do
                  adr_entitlement_default(entitlement:"max_non_rejected_adrs") do
                    account.entitlement.entitlement_default.max_non_rejected_adrs
                  end
                end
                td(class:"bb br tl pa-2") do
                  adr_entitlement_override(entitlement:"max_non_rejected_adrs") do
                    render(
                      TextFieldComponent.new(
                        label: { id: "max_non_rejected_adrs" },
                        form: form,
                        input_name: :max_non_rejected_adrs))
                  end
                end
                td(class: "bb    tr pa-2 bg-gray-800 f-3 fw-bold") do
                  adr_entitlement_effective(
                    show_warnings:"max_non_rejected_adrs",
                    entitlement: "max_non_rejected_adrs") do
                      effective(:max_non_rejected_adrs)
                    end
                end
              end
            end
          end
          div(class: "flex justify-end gap-3 mt-3") do
            render(
              ButtonComponent.new(
                color: :blue,
                label: "Update Entitlements",
                icon: "access-hand-key-icon",
              ))
          end
          div(class: "flex justify-end mt-3") do
            render(
              ButtonComponent.new(
                color: :red,
                size: :tiny,
                formaction: Admin::DeactivatedAccountsWithExternalIdHandler.routing(external_id: account.external_id),
                label: "Revoke Access",
                icon: "lock-icon",
                confirm: "This user will no longer be able to access their data",
              ))
          end
        end
      end
    end
    render(ConfirmationDialogComponent.new)
  end
end
