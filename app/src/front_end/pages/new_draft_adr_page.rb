class NewDraftAdrPage < AppPage
  attr_reader :form, :refines_adr, :replaces_adr, :projects
  def initialize(form: nil, authenticated_account:, flash:)
    @form                 = form || NewDraftAdrForm.new
    @flash                = flash
    @account_entitlements = authenticated_account.entitlements
    @projects             = authenticated_account.projects.active

    @refines_adr  = authenticated_account.accepted_adrs.find(external_id: @form.refines_adr_external_id)
    @replaces_adr = authenticated_account.accepted_adrs.find(external_id: @form.replaced_adr_external_id)

    if !@form.new? && @form.constraint_violations?
      @flash.alert = :new_adr_invalid
    end
  end

  def before_render
    if !@account_entitlements.can_add_new?
      @flash.alert = :add_new_limit_exceeded
      return redirect_to(AdrsPage)
    end
  end

  def page_template
    global_component(AnnouncementBannerComponent)
    header do
      h2(class: "tc ma-0 mt-3 ttu tracked-tight f-5") do
        t(:draft_new)
      end
      if refines_adr
        h3(class: "tc mt-0 f-4") do
          t(:refines, title: refines_adr.title)
        end
      end
      if replaces_adr
        h3(class: "tc mt-0 f-4") do
          t(:replaces, title: replaces_adr.title)
        end
      end
    end
    section(class: "pa-3") do
      render(Adrs::FormComponent.new(form, action: :new, projects: projects))
    end
  end
end
