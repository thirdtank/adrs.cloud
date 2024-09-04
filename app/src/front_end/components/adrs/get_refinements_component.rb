class Adrs::GetRefinementsComponent < AppComponent
  attr_reader :refined_by_adrs
  def initialize(refined_by_adrs:, shareable_paths: false)
    @refined_by_adrs =   refined_by_adrs
    @shareable_paths = !!shareable_paths
  end

  def path(adr)
    if @shareable_paths
      SharedAdrsByShareableIdPage.routing(shareable_id: adr.shareable_id)
    else
      AdrsByExternalIdPage.routing(external_id: adr.external_id)
    end
  end
end

