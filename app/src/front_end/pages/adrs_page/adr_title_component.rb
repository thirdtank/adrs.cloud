class AdrsPage::AdrTitleComponent < AppComponent
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
end
