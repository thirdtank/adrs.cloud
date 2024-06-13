class Components::Adrs::GetRefinements < AppComponent
  attr_reader :refined_by_adrs
  def initialize(refined_by_adrs:)
    @refined_by_adrs = refined_by_adrs
  end
end

