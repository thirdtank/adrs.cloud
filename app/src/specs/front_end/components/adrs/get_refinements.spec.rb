require "spec_helper"
require "front_end/components/adrs/get_refinements"

RSpec.describe Components::Adrs::GetRefinements do
  let(:helpers) { Object.new.extend(AppViewHelpers) }
  context "public_paths requested" do
    it "uses the public path for each ADR" do
      account = create(:account)
      adr_being_refined = create(:adr, :accepted, account: account)
      adrs = [
        create(:adr, :accepted, refines_adr_id: adr_being_refined.id, account: account, public_id: "abcdefg"),
        create(:adr, :accepted, refines_adr_id: adr_being_refined.id, account: account, public_id: "wrtdfgf"),
        create(:adr, :accepted, refines_adr_id: adr_being_refined.id, account: account, public_id: "95jf9ej"),
      ]
      component = described_class.new(refined_by_adrs: adrs, public_paths: true)

      parsed_html = render_and_parse(component)

      adrs.each do |adr|
        expect(parsed_html.css("a[href='#{helpers.public_adr_path(adr)}']").length).to eq(1)
        expect(parsed_html.css("a[href='#{helpers.adr_path(adr)}']").length).to        eq(0)
      end
    end
  end

  context "public_paths not requested" do
    it "uses the private path for each ADR" do
      account = create(:account)
      adr_being_refined = create(:adr, :accepted, account: account)
      adrs = [
        create(:adr, :accepted, refines_adr_id: adr_being_refined.id, account: account, public_id: "abcdefg"),
        create(:adr, :accepted, refines_adr_id: adr_being_refined.id, account: account, public_id: "wrtdfgf"),
        create(:adr, :accepted, refines_adr_id: adr_being_refined.id, account: account, public_id: "95jf9ej"),
      ]
      component = described_class.new(refined_by_adrs: adrs)

      parsed_html = render_and_parse(component)

      adrs.each do |adr|
        expect(parsed_html.css("a[href='#{helpers.public_adr_path(adr)}']").length).to eq(0)
        expect(parsed_html.css("a[href='#{helpers.adr_path(adr)}']").length).to        eq(1)
      end
    end
  end


end
