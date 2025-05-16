class Projects::FormComponent < AppComponent
  attr_reader :form, :action_label, :form_action, :go_back_label, :account_external_id
  def initialize(form, action:, external_id: nil, account_external_id:)

    @form                = form
    @account_external_id = account_external_id

    case action
    when :new
      @action_label  = t("actions.new")
      @form_action   = NewProjectForm.routing
      @go_back_label = t(:nevermind)
    when :edit
      @external_id   = external_id_required!(external_id:,action:)
      @action_label  = t("actions.edit")
      @form_action   = EditProjectByExternalIdPage.routing(external_id: external_id)
      @go_back_label = t(:back)
    else
      raise "Action '#{action}' is not known"
    end
  end

  def view_template
    brut_form do
      FormTag(
        action: @form_action.to_s,
        method:"post",
        class:"flex flex-column gap-2 shadow-2-ns mh-auto pa-4-ns br-1 bg-white-ish-ns w-60-ns"
      ) do
        render(
          TextFieldComponent.new(
            label: t("name.label"),
            form: form,
            input_name: "name",
            placeholder: t("name.placeholder"),
            autofocus: true
          )
        )
        render(
          TextareaComponent.new(
            label: t("description.label"),
            form: form,
            input_name: "description",
            placeholder: t("description.placeholder"),
            autofocus: false
          )
        )
        render(
          CheckboxComponent.new(
            label: t("adrs_shared_by_default.label"),
            form: form,
            input_name: "adrs_shared_by_default"
          )
        )
        div(class: "mt-2 flex justify-center") do
          render(ButtonComponent.new(size: "normal", color: "blue", label: action_label, icon: "layer-icon"))
        end
        a(
          href: AccountByExternalIdPage.routing(external_id: account_external_id, tab: :projects),
          class: "red-300"
        ) do
          span(role:"none") { raw(safe("&larr;")) }
          whitespace
          plain(go_back_label.to_s)
        end
      end
    end
  end

private

  def external_id_required!(external_id:,action:)
    if external_id.nil?
      bug! "You may not create a #{self.class} with action #{action} and no external_id."
    end
    external_id
  end
end
