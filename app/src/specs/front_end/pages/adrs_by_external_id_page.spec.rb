require "spec_helper"

RSpec.describe AdrsByExternalIdPage do
  context "info message" do
    it "shows the info message" do
      adr = create(:adr)
      page = described_class.new(account: adr.account, external_id: adr.external_id, flash: flash_from(notice: "actions.adrs.accepted"))

      html_locator = Support::HtmlLocator.new(render_and_parse(page))
      expect(html_locator.element!("aside[role='status']").text.to_s.strip).to eq("ADR Accepted")
    end
  end
  context "draft" do
    it "shows the draft label and renders content in markdown" do
      adr = create(:adr, because: "Because *this* is a test of `markdown`")
      page = described_class.new(account: adr.account, external_id: adr.external_id, flash: empty_flash)

      html_locator = Support::HtmlLocator.new(render_and_parse(page))
      expect(html_locator.element!("aside[role='note']").text.to_s.strip).to eq("DRAFT")
      expect(html_locator.element!("[aria-label='because']").inner_html).to include("Because <em>this</em> is a test of <code>markdown</code>")
    end
  end
  context "replaced" do
    it "shows the replaced ADR's title and time, and replace/refine buttons are hidden" do
      account = create(:account)

      replacing_adr = create(:adr, :accepted, account: account)
      replaced_adr  = create(:adr, :accepted, account: account, replaced_by_adr_id: replacing_adr.id)

      DataModel::ProposedAdrReplacement.new(
        replacing_adr_id: replacing_adr.id,
        replaced_adr_id: replaced_adr.id,
        created_at: Time.now,
      )

      page = described_class.new(account: account, external_id: replaced_adr.external_id, flash: empty_flash)

      parsed_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(parsed_html)

      expect(parsed_html.text).to include("Replaced #{replacing_adr.accepted_at}")
      expect(parsed_html.text).to match(/Originally\s+Accepted/)
      link = html_locator.element!("a[href='#{page.adr_path(replacing_adr)}']")
      expect(link.text).to eq(replacing_adr.title)
      expect(parsed_html.css("button[title='Replace']").size).to eq(0)
      expect(parsed_html.css("button[title='Refine']").size).to eq(0)
    end
  end
  context "refines another ADR" do
    it "shows the replaced ADR's title and time, and replace/refine buttons are hidden" do
      account = create(:account)

      refined_adr  = create(:adr, :accepted, account: account)
      refined_adr.update(external_id: "refined")
      refining_adr = create(:adr, :accepted, account: account, refines_adr_id: refined_adr.id)
      refining_adr.update(external_id: "refining")

      page = described_class.new(account: account, external_id: refining_adr.external_id, flash: empty_flash)

      parsed_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(parsed_html)

      link = html_locator.element!("a[href='#{page.adr_path(refined_adr)}']")
      expect(link.text).to eq(refined_adr.title)

      expect(parsed_html.css("button[title='Replace']").size).to eq(1)
      expect(parsed_html.css("button[title='Refine']").size).to eq(1)
    end
  end
  context "accepted, not replaced" do
    it "shows that it was accepted and allows replacement and refinement" do
      adr  = create(:adr, :accepted)

      page = described_class.new(account: adr.account, external_id: adr.external_id, flash: empty_flash)

      parsed_html = render_and_parse(page)

      expect(parsed_html.text).to include("Accepted")
      expect(parsed_html.text).not_to match(/Originally\s+Accepted/)

      expect(parsed_html.css("button[title='Replace']").size).to eq(1)
      expect(parsed_html.css("button[title='Refine']").size).to eq(1)
      expect(parsed_html.css("aside[role='note']").length).to eq(0)
    end
  end
  context "rejected" do
    it "shows that it was accepted and allows replacement and refinement" do
      adr = create(:adr, rejected_at: Time.now)

      page = described_class.new(account: adr.account, external_id: adr.external_id, flash: empty_flash)

      parsed_html = render_and_parse(page)

      expect(parsed_html.text).not_to include("Accepted")
      expect(parsed_html.text).to include("Rejected")

      expect(parsed_html.css("button[title='Replace']").size).to eq(0)
      expect(parsed_html.css("button[title='Refine']").size).to eq(0)
      expect(parsed_html.css("aside[role='note']").length).to eq(0)
    end
  end
  context "shared" do
    it "disables the public button, enables the private one" do
      adr  = create(:adr, :accepted, shareable_id: "some-id")

      page = described_class.new(account: adr.account, external_id: adr.external_id, flash: empty_flash)

      parsed_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(render_and_parse(page))

      expect(parsed_html.text).to include("Accepted")
      expect(parsed_html.text).not_to match(/Originally\s+Accepted/)

      element = html_locator.element!("button[disabled]")
      expect(element.text.strip).to eq("Share")
      element = html_locator.element!("button[title='Stop Sharing']")
      expect(element).not_to have_html_attribute(disabled: true)
    end
  end
  context "private" do
    it "disables the private button, enables the public one" do
      adr  = create(:adr, :accepted, shareable_id: nil)

      page = described_class.new(account: adr.account, external_id: adr.external_id, flash: empty_flash)

      parsed_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(render_and_parse(page))

      expect(parsed_html.text).to include("Accepted")
      expect(parsed_html.text).not_to match(/Originally\s+Accepted/)

      element = html_locator.element!("button[disabled]")
      expect(element.text.strip).to eq("Stop Sharing")
      element = html_locator.element!("button[title='Share']")
      expect(element).not_to have_html_attribute(disabled: true)
    end
  end
end
