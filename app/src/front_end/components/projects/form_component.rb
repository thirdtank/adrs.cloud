class Projects::FormComponent < AppComponent
  attr_reader :form, :action_label, :form_action, :go_back_label, :account_external_id
  def initialize(form, action:, external_id: nil, account_external_id:)

    @form                = form
    @account_external_id = account_external_id

    case action
    when :new
      @action_label  = t(component: [ :actions, :new ])
      @form_action   = NewProjectForm.routing
      @go_back_label = t(:nevermind)
    when :edit
      @external_id   = external_id_required!(external_id:,action:)
      @action_label  = t(component: [ :actions, :edit ])
      @form_action   = EditProjectByExternalIdPage.routing(external_id: external_id)
      @go_back_label = t(:back)
    else
      raise "Action '#{action}' is not known"
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
