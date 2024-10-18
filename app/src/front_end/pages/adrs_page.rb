class AdrsPage < AppPage

  attr_reader :tag, :tab, :entitlements, :authenticated_account, :project

  def initialize(authenticated_account:, tag: nil, tab: "accepted", project_external_id: nil)
    @authenticated_account = authenticated_account
    @tag                   = RichString.new(tag).to_s_or_nil
    @project               = if project_external_id == "ALL" || project_external_id.nil?
                               nil
                             else
                               Project.find!(external_id: project_external_id, account: authenticated_account.account)
                             end

    @adrs                  = @authenticated_account.adrs.search(tag: @tag,project: @project)

    num_non_rejected_adrs = @adrs.length - self.rejected_adrs.length

    @entitlements = @authenticated_account.entitlements
    @tab          = tab.to_sym
  end

  def filtered? = !!@tag || !!@project

  def accepted_adrs = @adrs.select(&:accepted?).reject(&:replaced?).sort_by(&:accepted_at)
  def replaced_adrs = @adrs.select(&:replaced?).sort_by { |adr|
    adr.replaced_by_adr.accepted_at
  }
  def draft_adrs    = @adrs.reject(&:accepted?).reject(&:rejected?).sort_by(&:created_at)
  def rejected_adrs = @adrs.select(&:rejected?).sort_by(&:rejected_at)

  def can_add_new? = @entitlements.can_add_new?

  def project_select
    component(Brut::FrontEnd::Components::Inputs::Select.new(
      name: "project_external_id",
      include_blank: { value: "ALL", text_content: "All" },
      options: authenticated_account.projects,
      selected_value: project&.external_id,
      value_attribute: :external_id,
      option_text_attribute: :name,
      html_attributes: { class: "w-6" }))
  end

end

