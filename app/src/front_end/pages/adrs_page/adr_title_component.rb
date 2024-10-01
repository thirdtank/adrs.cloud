class AdrsPage::AdrTitleComponent < AppComponent
  attr_reader :adr
  def initialize(adr:)
    @adr = adr
  end

  def tags = adr.tags(phony_shared: false)
end
