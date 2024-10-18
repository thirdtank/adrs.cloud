class Adrs::FormComponent < AppComponent

  attr_reader :form, :action_label, :form_action, :go_back_label, :projects_input
  def initialize(form, action:, external_id: nil, projects: [])
    @form = form
    @projects_input = Brut::FrontEnd::Components::Inputs::Select.for_form_input(
      form: form,
      input_name: :project_external_id,
      html_attributes: { class: "w-100 f-3" },
      options: projects,
      selected_value: form.project_external_id,
      value_attribute: :external_id,
      option_text_attribute: :name,
    )
    case action
    when :new
      @action_label  = t(component: [ :actions, :save_draft ])
      @form_action   = NewDraftAdrForm.routing
      @go_back_label = t(:nevermind)
      @ajax_submit   = false
    when :edit
      @external_id   = external_id_required!(external_id:,action:)
      @action_label  = t(component: [ :actions, :update_draft ])
      @form_action   = EditDraftAdrWithExternalIdForm.routing(external_id: @external_id)
      @go_back_label = t(:back)
      @ajax_submit   = true
    when :replace
      @action_label  = t(component: [ :actions, :save_replacement_draft ])
      @form_action   = NewDraftAdrHandler.routing
      @go_back_label = t(:nevermind)
      @ajax_submit   = false
    when :refine
      @action_label  = t(component: [ :actions, :save_refining_draft ])
      @form_action   = NewDraftAdrHandler.routing
      @go_back_label = t(:nevermind)
      @ajax_submit   = false
    else
      raise "Action '#{action}' is not known"
    end
  end

  def ajax_submit? = @ajax_submit

  def adr_textarea(name)
    component(
      Adrs::TextareaComponent.new(
        form: @form,
        input_name: name,
        label: t(component: [ :fields, name, :label ]),
        context: t(component: [ :fields, name, :context ])
      )
    )
  end

  def reject_button
    if !@form.new_record?
      component(
        ButtonComponent.new(
          formaction: RejectedAdrsWithExternalIdHandler.routing(external_id: @external_id),
          size: "small",
          color: "red",
          label: t(component: [ :actions, :reject ]),
          icon: "recycle-bin-line-icon",
          confirm: "You can't bring this back other than re-creating it by hand"
        )
      )
    end
  end

  def accept_button
    if !@form.new_record?
      component(
        ButtonComponent.new(
          formaction: AcceptedAdrsWithExternalIdForm.routing(external_id: @external_id),
          size: "small",
          color: "green",
          label: t(component: [ :actions, :accept ]),
          icon: "quality-badge-checkmark-icon",
          confirm: "You won't be able to change this ADR after you accept it"
        )
      )
    end
  end

private

  def external_id_required!(external_id:,action:)
    if external_id.nil?
      raise Brut::BackEnd::Errors::Bug, "You may not create a #{self.class} with action #{action} and no external_id."
    end
    external_id
  end

end

