class Components::Adrs::Form < AppComponent
  attr_reader :form, :action_label, :form_action, :go_back_label
  def initialize(form, action:)
    @form = form
    case action
    when :new
      @action_label  = "Save Draft"
      @form_action   = Brut.container.routing.for(NewDraftAdrForm)
      @go_back_label = "Nevermind"
      @ajax_submit   = false
    when :edit
      @action_label  = "Update Draft"
      @form_action   = Brut.container.routing.for(EditDraftAdrWithExternalIdForm, external_id: @form.external_id)
      @go_back_label = "Back"
      @ajax_submit   = true
    when :replace
      @action_label  = "Save Replacement Draft"
      @form_action   = "/draft_adrs"
      @go_back_label = "Nevermind"
      @ajax_submit   = false
    when :refine
      @action_label  = "Save Refining Draft"
      @form_action   = "/draft_adrs"
      @go_back_label = "Nevermind"
      @ajax_submit   = false
    else
      raise "Action '#{action}' is not known"
    end
  end

  def ajax_submit? = @ajax_submit

  def adr_textarea(name:, prefix:, label:)
    component(Components::Adrs::Textarea.new(form: @form, input_name: name, prefix: prefix, label: label))
  end

  def reject_button
    if !@form.new_record?
      component(
        Components::Button.new(
          formaction: Brut.container.routing.for(RejectedAdrsWithExternalIdHandler, external_id: @form.external_id),
          size: "small",
          color: "red",
          label: "Reject ADR",
          icon: "recycle-bin-line-icon",
          confirm: "You can't bring this back other than re-creating it by hand"
        )
      )
    end
  end

  def accept_button
    if !@form.new_record?
      component(
        Components::Button.new(
          formaction: Brut.container.routing.for(AcceptedAdrsWithExternalIdForm, external_id: @form.external_id),
          size: "small",
          color: "green",
          label: "Accept ADR",
          icon: "quality-badge-checkmark-icon",
          confirm: "You won't be able to change this ADR after you accept it"
        )
      )
    end
  end
end

