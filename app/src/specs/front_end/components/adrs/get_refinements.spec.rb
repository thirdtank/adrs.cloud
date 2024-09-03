require "spec_helper"
require "front_end/components/adrs/get_refinements"

RSpec.describe Components::Adrs::GetRefinements, component: true do
  context "shareable_paths requested" do
    it "uses the public path for each ADR" do
      account = create(:account)
      adr_being_refined = create(:adr, :accepted, account: account)
      adrs = [
        create(:adr, :accepted, refines_adr_id: adr_being_refined.id, account: account, shareable_id: "abcdefg"),
        create(:adr, :accepted, refines_adr_id: adr_being_refined.id, account: account, shareable_id: "wrtdfgf"),
        create(:adr, :accepted, refines_adr_id: adr_being_refined.id, account: account, shareable_id: "95jf9ej"),
      ]
      component = described_class.new(refined_by_adrs: adrs, shareable_paths: true)

      parsed_html = render_and_parse(component)

      adrs.each do |adr|
        expect(parsed_html.css("a[href='#{Brut.container.routing.for(SharedAdrsByShareableIdPage, shareable_id: adr.shareable_id)}']").length).to eq(1)
        expect(parsed_html.css("a[href='#{Brut.container.routing.for(AdrsByExternalIdPage, external_id: adr.external_id)}']").length).to eq(0)
      end
    end
  end

  context "shareable_paths not requested" do
    it "uses the private path for each ADR" do
      account = create(:account)
      adr_being_refined = create(:adr, :accepted, account: account)
      adrs = [
        create(:adr, :accepted, refines_adr_id: adr_being_refined.id, account: account, shareable_id: "abcdefg"),
        create(:adr, :accepted, refines_adr_id: adr_being_refined.id, account: account, shareable_id: "wrtdfgf"),
        create(:adr, :accepted, refines_adr_id: adr_being_refined.id, account: account, shareable_id: "95jf9ej"),
      ]
      component = described_class.new(refined_by_adrs: adrs)

      parsed_html = render_and_parse(component)

      adrs.each do |adr|
        expect(parsed_html.css("a[href='#{Brut.container.routing.for(SharedAdrsByShareableIdPage, shareable_id: adr.shareable_id)}']").length).to eq(0)
        expect(parsed_html.css("a[href='#{Brut.container.routing.for(AdrsByExternalIdPage, external_id: adr.external_id)}']").length).to eq(1)
      end
    end
  end


end
