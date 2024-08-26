require "spec_helper"
require "front_end/pages/adrs/public_get"

RSpec.describe Pages::Adrs::PublicGet do
  context "replaced" do
    context "replacing ADR is private" do
      it "shows the replaced ADR's title and time, shows it's been replaced, but not the name or link" do
        account = create(:account)

        replacing_adr = create(:adr, :accepted, account: account)
        replaced_adr  = create(:adr, :accepted, account: account, public_id: "some-id", replaced_by_adr_id: replacing_adr.id)

        DataModel::ProposedAdrReplacement.new(
          replacing_adr_id: replacing_adr.id,
          replaced_adr_id: replaced_adr.id,
          created_at: Time.now,
        )
        page = described_class.new(adr: replaced_adr, account: create(:account))


        parsed_html = render_and_parse(page)
        html_locator = Support::HtmlLocator.new(parsed_html)

        expect(parsed_html.text).to match(/Originally\s+Accepted/)
        expect(parsed_html.text).to match(/Replaced\s+#{Regexp.escape(replacing_adr.accepted_at.to_s)}/)
        expect(parsed_html.text).not_to include(replacing_adr.title)
        expect(parsed_html.css("[href='#{page.adr_path(replacing_adr)}']").length).to eq(0)
        link = html_locator.element("a[href='#{page.public_adr_path(replacing_adr, on_private: nil)}']")
        expect(link).to eq(nil)
      end
    end
    context "replacing ADR is public" do
      it "shows the replaced ADR's title and time, and replace/refine buttons are hidden" do
        account = create(:account)

        replacing_adr = create(:adr, :accepted, account: account, public_id: "some-other-id", )
        replaced_adr  = create(:adr, :accepted, account: account, public_id: "some-id", replaced_by_adr_id: replacing_adr.id)

        DataModel::ProposedAdrReplacement.new(
          replacing_adr_id: replacing_adr.id,
          replaced_adr_id: replaced_adr.id,
          created_at: Time.now,
        )
        page = described_class.new(adr: replaced_adr, account: create(:account))


        parsed_html = render_and_parse(page)
        html_locator = Support::HtmlLocator.new(parsed_html)

        expect(parsed_html.text).to match(/Replaced\s+#{Regexp.escape(replacing_adr.accepted_at.to_s)}/)
        expect(parsed_html.text).to match(/Originally\s+Accepted/)
        expect(parsed_html.css("[href='#{page.adr_path(replacing_adr)}']").length).to eq(0)
        link = html_locator.element!("a[href='#{page.public_adr_path(replacing_adr)}']")
        expect(link.text.to_s.strip).to eq(replacing_adr.title)
      end
    end
  end
  context "refines another ADR" do
    context "other ADR is private" do
      it "shows the replaced ADR's title and time, but nothing about refinement" do
        account = create(:account)

        refined_adr  = create(:adr, :accepted, account: account)
        refined_adr.update(external_id: "refined")
        refining_adr = create(:adr, :accepted, account: account, public_id: "some-id", refines_adr_id: refined_adr.id)
        refining_adr.update(external_id: "refining")

        page = described_class.new(adr: refining_adr, account: create(:account))

        parsed_html = render_and_parse(page)
        html_locator = Support::HtmlLocator.new(parsed_html)

        link = html_locator.element("a[href='#{page.public_adr_path(refined_adr, on_private: nil)}']")
        expect(link).to eq(nil)
        expect(parsed_html.text).not_to include(refined_adr.title)
      end
    end
    context "other ADR is public" do
      it "shows the replaced ADR's title and time, but nothing about refinement" do
        account = create(:account)

        refined_adr  = create(:adr, :accepted, account: account, public_id: "some-other-id")
        refined_adr.update(external_id: "refined")
        refining_adr = create(:adr, :accepted, account: account, public_id: "some-id", refines_adr_id: refined_adr.id)
        refining_adr.update(external_id: "refining")

        page = described_class.new(adr: refining_adr, account: create(:account))

        parsed_html = render_and_parse(page)
        html_locator = Support::HtmlLocator.new(parsed_html)

        link = html_locator.element!("a[href='#{page.public_adr_path(refined_adr, on_private: nil)}']")
        expect(link.text.to_s.strip).to eq(refined_adr.title)
      end
    end
  end
  context "accepted, not replaced" do
    it "shows that it was accepted and allows replacement and refinement" do
      adr  = create(:adr, :accepted)
      adr = create(:adr, because: "Because *this* is a test of `markdown`")

      page = described_class.new(adr: adr, account: create(:account))

      parsed_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(parsed_html)

      expect(parsed_html.text).to include("Accepted")
      expect(parsed_html.text).not_to match(/Originally\s+Accepted/)
      expect(html_locator.element!("[aria-label='because']").inner_html).to include("Because <em>this</em> is a test of <code>markdown</code>")
    end
  end
end
