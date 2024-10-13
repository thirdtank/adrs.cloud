class Adrs::GetRefinementsComponent < AppComponent
  attr_reader :refined_by_adrs
  def initialize(refined_by_adrs:, shareable_paths: false, gradient: true, constrain_width: true)
    @refined_by_adrs =   refined_by_adrs
    @shareable_paths = !!shareable_paths
    @gradient        =   gradient
    @constrain_width =   constrain_width
  end

  def gradient?        = @gradient
  def constrain_width? = @constrain_width

  def path(adr)
    if @shareable_paths
      SharedAdrsByShareableIdPage.routing(shareable_id: adr.shareable_id)
    else
      AdrsByExternalIdPage.routing(external_id: adr.external_id)
    end
  end
end

