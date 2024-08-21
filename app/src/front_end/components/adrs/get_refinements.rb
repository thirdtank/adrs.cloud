class Components::Adrs::GetRefinements < AppComponent
  attr_reader :refined_by_adrs
  def initialize(refined_by_adrs:, public_paths: false)
    @refined_by_adrs = refined_by_adrs
    @public_paths = !!public_paths
  end

  def path(adr)
    if @public_paths
      public_adr_path(adr)
    else
      adr_path(adr)
    end
  end
end

