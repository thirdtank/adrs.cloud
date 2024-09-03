require "spec_helper"

RSpec.describe SharedAdrsByShareableIdPage do
  context "replaced" do
    context "replacing ADR is private" do
      it "shows the replaced ADR's title and time, shows it's been replaced, but not the name or link" do
        account = create(:account)

        replacing_adr = create(:adr, :accepted, account: account)
        replaced_adr  = create(:adr, :accepted, account: account, shareable_id: "some-id", replaced_by_adr_id: replacing_adr.id)

        DataModel::ProposedAdrReplacement.new(
          replacing_adr_id: replacing_adr.id,
          replaced_adr_id: replaced_adr.id,
          created_at: Time.now,
        )
        page = described_class.new(shareable_id: replaced_adr.shareable_id, account: create(:account))


        parsed_html = render_and_parse(page)
        html_locator = Support::HtmlLocator.new(parsed_html)

        expect(parsed_html.text).to match(/Originally\s+Accepted/)
        expect(parsed_html.text).to match(/Replaced\s+#{Regexp.escape(replacing_adr.accepted_at.to_s)}/)
        expect(parsed_html.text).not_to include(replacing_adr.title)
        expect(parsed_html.css("[href='#{page.adr_path(replacing_adr)}']").length).to eq(0)
        link = html_locator.element("a[href='#{Brut.container.routing.for(described_class, shareable_id: replacing_adr.shareable_id)}']")
        expect(link).to eq(nil)
      end
    end
    context "replacing ADR is public" do
      it "shows the replaced ADR's title and time, and replace/refine buttons are hidden" do
        account = create(:account)

        replacing_adr = create(:adr, :accepted, account: account, shareable_id: "some-other-id", )
        replaced_adr  = create(:adr, :accepted, account: account, shareable_id: "some-id", replaced_by_adr_id: replacing_adr.id)

        DataModel::ProposedAdrReplacement.new(
          replacing_adr_id: replacing_adr.id,
          replaced_adr_id: replaced_adr.id,
          created_at: Time.now,
        )
        page = described_class.new(shareable_id: replaced_adr.shareable_id, account: create(:account))


        parsed_html = render_and_parse(page)
        html_locator = Support::HtmlLocator.new(parsed_html)

        expect(parsed_html.text).to match(/Replaced\s+#{Regexp.escape(replacing_adr.accepted_at.to_s)}/)
        expect(parsed_html.text).to match(/Originally\s+Accepted/)
        expect(parsed_html.css("[href='#{page.adr_path(replacing_adr)}']").length).to eq(0)
        link = html_locator.element!("a[href='#{Brut.container.routing.for(described_class, shareable_id: replacing_adr.shareable_id)}']")
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
        refining_adr = create(:adr, :accepted, account: account, shareable_id: "some-id", refines_adr_id: refined_adr.id)
        refining_adr.update(external_id: "refining")

        page = described_class.new(shareable_id: refining_adr.shareable_id, account: create(:account))

        parsed_html = render_and_parse(page)
        html_locator = Support::HtmlLocator.new(parsed_html)

        link = html_locator.element("a[href='#{Brut.container.routing.for(described_class, shareable_id: refined_adr.shareable_id)}']")
        expect(link).to eq(nil)
        expect(parsed_html.text).not_to include(refined_adr.title)
      end
    end
    context "other ADR is public" do
      it "shows the replaced ADR's title and time, but nothing about refinement" do
        account = create(:account)

        refined_adr  = create(:adr, :accepted, account: account, shareable_id: "some-other-id")
        refined_adr.update(external_id: "refined")
        refining_adr = create(:adr, :accepted, account: account, shareable_id: "some-id", refines_adr_id: refined_adr.id)
        refining_adr.update(external_id: "refining")

        page = described_class.new(shareable_id: refining_adr.shareable_id, account: create(:account))

        parsed_html = render_and_parse(page)
        html_locator = Support::HtmlLocator.new(parsed_html)

        link = html_locator.element!("a[href='#{Brut.container.routing.for(described_class, shareable_id: refined_adr.shareable_id)}']")
        expect(link.text.to_s.strip).to eq(refined_adr.title)
      end
    end
  end
  context "accepted, not replaced" do
    it "shows that it was accepted and allows replacement and refinement" do
      adr = create(:adr, :accepted, shareable_id: "some-other-id-etc", because: "Because *this* is a test of `markdown`")

      page = described_class.new(shareable_id: adr.shareable_id, account: create(:account))

      parsed_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(parsed_html)

      expect(parsed_html.text).to include("Accepted")
      expect(parsed_html.text).not_to match(/Originally\s+Accepted/)
      expect(html_locator.element!("[aria-label='because']").inner_html).to include("Because <em>this</em> is a test of <code>markdown</code>")
    end
  end
  it "blows up if id is nil" do
    expect {
      described_class.new(shareable_id: nil, account: create(:account))
    }.to raise_error(ArgumentError)
  end
end
