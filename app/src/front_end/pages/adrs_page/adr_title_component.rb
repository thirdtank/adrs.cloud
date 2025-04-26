class AdrsPage::AdrTitleComponent < AppComponent
  def page_name = "AdrsPage"
  attr_reader :adr
  def initialize(adr:)
    @adr = adr
  end

  def title = @adr.title

  def replaced_by_adr
    @replaced_by_adr ||= @adr.replaced_by_adr
  end

  def refines_adr
    @refines_adr ||= @adr.refines_adr
  end
  def replaced_adr
    @replaced_adr ||= @adr.replaced_adr
  end
  def proposed_to_replace_adr
    @proposed_to_replace_adr ||= @adr.proposed_to_replace_adr
  end

  def tags = adr.tags

  def view_template
    div do
      div(class: "f-4 lh-title") { adr.title }
      if tags.any?
        div(class:"flex flex-wrap gap-2 mt-2") do
          tags.each do |tag|
            render(Adrs::TagComponent.new(tag:, compact: true))
          end
        end
      end
    end
    if replaced_by_adr || refines_adr || replaced_adr || proposed_to_replace_adr
      div(class: "f-1 i mt-2") do
        if replaced_by_adr
          t(page: [ :title_additions, :replaced_by ]) do
            a(href:AdrsByExternalIdPage.routing(external_id: replaced_by_adr.external_id).to_s, class:"blue-300") do
              replaced_by_adr.title
            end
          end.to_s
        end
        if refines_adr
          t(page: [ :title_additions, :refines ]) do
            a(href: AdrsByExternalIdPage.routing(external_id: refines_adr.external_id).to_s, class: "blue-300") do
              refines_adr.title
            end
          end.to_s
        end
        if replaced_adr
          t(page: [ :title_additions, :replaces ]) do
            a(href: AdrsByExternalIdPage.routing(external_id: replaced_adr.external_id).to_s, class: "blue-300") do
              replaced_adr.title
            end
          end.to_s
        elsif proposed_to_replace_adr
          t(page: [ :title_additions, :proposed_replacement ]) do
            a(href: AdrsByExternalIdPage.routing(external_id: proposed_to_replace_adr.external_id).to_s, class:"blue-300") do
              proposed_to_replace_adr.title
            end
          end.to_s
        end
      end
    end
  end
end
