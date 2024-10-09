require "spec_helper"

RSpec.describe AdrsByExternalIdPage do
  context "info message" do
    it "shows the info message" do
      authenticated_account = create(:authenticated_account)
      adr                   = create(:adr, account: authenticated_account.account)
      request_context[:flash].notice = :adr_accepted

      page = described_class.new(authenticated_account:,
                                 external_id: adr.external_id)

      html_locator = Support::HtmlLocator.new(render_and_parse(page))
      expect(html_locator.element!("[role='status']").text).to include("ADR Accepted")
    end
  end
  context "draft" do
    it "shows the draft label and renders content in markdown" do
      authenticated_account = create(:authenticated_account)
      adr                   = create(:adr, because: "Because *this* is a test of `markdown`", account: authenticated_account.account)

      page = described_class.new(authenticated_account:,
                                 external_id: adr.external_id)

      html_locator = Support::HtmlLocator.new(render_and_parse(page))
      expect(html_locator.element!("aside[role='note']").text.to_s.strip).to eq("DRAFT")
      expect(html_locator.element!("[aria-label='because']").inner_html).to include("Because <em>this</em> is a test of <code>markdown</code>")
    end
  end
  context "replaced" do
    it "shows the replaced ADR's title and time, and replace/refine buttons are hidden" do
      authenticated_account = create(:authenticated_account)
      replacing_adr         = create(:adr, :accepted, account: authenticated_account.account)
      replaced_adr          = create(:adr, :accepted, replaced_by_adr_id: replacing_adr.id, account: authenticated_account.account)

      DB::ProposedAdrReplacement.new(
        replacing_adr_id: replacing_adr.id,
        replaced_adr_id: replaced_adr.id,
      )

      page = described_class.new(authenticated_account:,
                                 external_id: replaced_adr.external_id)

      parsed_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(parsed_html)

      timestamp = html_locator.element!("time[datetime='#{replacing_adr.accepted_at.strftime("%Y-%m-%d %H:%M:%S.%6N %Z")}']")

      expect(parsed_html.text).to match(/Originally\s+Accepted/)
      link = html_locator.element!("a[href='#{page.adr_path(replacing_adr)}']")
      expect(link.text).to eq(replacing_adr.title)
      expect(parsed_html.css("button[title='Replace']").size).to eq(0)
      expect(parsed_html.css("button[title='Refine']").size).to eq(0)
    end
  end
  context "refines another ADR" do
    it "shows the replaced ADR's title and time, and replace/refine buttons are hidden" do
      authenticated_account = create(:authenticated_account)
      refined_adr           = create(:adr, :accepted, account: authenticated_account.account)
      refining_adr          = create(:adr, :accepted, refines_adr_id: refined_adr.id, account: authenticated_account.account)

      page = described_class.new(authenticated_account:,
                                 external_id: refining_adr.external_id)

      parsed_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(parsed_html)

      link = html_locator.element!("a[href='#{page.adr_path(refined_adr)}']")
      expect(link.text).to eq(refined_adr.title)

      expect(parsed_html.css("button[title='Replace']").size).to eq(1)
      expect(parsed_html.css("button[title='Refine']").size).to eq(1)
    end
  end
  context "accepted, not replaced" do
    context "ADR limit exceeded" do
      it "the Replace and Refine buttons are disabled" do
        authenticated_account = create(:authenticated_account)
        adr                   = create(:adr, :accepted, account: authenticated_account.account)

        adr.account.entitlement.update(max_non_rejected_adrs: 3)
        create(:adr, account: authenticated_account.account)
        create(:adr, account: authenticated_account.account)

        page = described_class.new(authenticated_account:,
                                   external_id: adr.external_id)

        parsed_html = render_and_parse(page)

        expect(parsed_html.text).to include("Accepted")

        replace_button = parsed_html.css("button[aria-label='Replace'][disabled]")[0]
        expect(replace_button).not_to eq(nil)
        expect(replace_button[:title]).to eq("You've reached your limit")

        refine_button = parsed_html.css("button[aria-label='Refine'][disabled]")[0]
        expect(refine_button).not_to eq(nil)
        expect(refine_button[:title]).to eq("You've reached your limit")

      end
    end
    it "shows that it was accepted and allows replacement and refinement" do
      authenticated_account = create(:authenticated_account)
      adr                   = create(:adr, :accepted, account: authenticated_account.account)

      page = described_class.new(authenticated_account:,
                                 external_id: adr.external_id)

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
      authenticated_account = create(:authenticated_account)
      adr                   = create(:adr, rejected_at: Time.now, account: authenticated_account.account)

      page = described_class.new(authenticated_account:,
                                 external_id: adr.external_id)

      parsed_html = render_and_parse(page)

      expect(parsed_html.text).not_to include("Accepted")
      expect(parsed_html.text).to include("Rejected")

      expect(parsed_html.css("button[title='Replace']").size).to eq(0)
      expect(parsed_html.css("button[title='Refine']").size).to eq(0)
      expect(parsed_html.css("aside[role='note']").length).to eq(0)
    end
  end
  context "shared" do
    it "disables the public button, enables the private one and omits 'shared' from the tag editor" do
      authenticated_account = create(:authenticated_account)
      adr                   = create(:adr, :accepted,
                                     shareable_id: "some-id",
                                     tags: [ "foo", "bar" ],
                                     account: authenticated_account.account)

      page = described_class.new(authenticated_account:,
                                 external_id: adr.external_id)

      parsed_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(render_and_parse(page))

      expect(parsed_html.text).to include("Accepted")
      expect(parsed_html.text).not_to match(/Originally\s+Accepted/)

      element = html_locator.element!("button[disabled]")
      expect(element.text.strip).to include("Share")
      element = html_locator.element!("button[title='Stop Sharing']")
      expect(element).not_to have_html_attribute(disabled: true)

      element = html_locator.element!("adr-tag-editor-edit textarea")
      expect(element.text).to eq(Tags.from_array(array: adr.tags(phony_shared: false)).to_s)
    end
  end
  context "private" do
    it "disables the private button, enables the public one" do
      authenticated_account = create(:authenticated_account)
      adr                   = create(:adr, :accepted, shareable_id: nil, account: authenticated_account.account)

      page = described_class.new(authenticated_account:,
                                 external_id: adr.external_id)

      parsed_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(render_and_parse(page))

      expect(parsed_html.text).to include("Accepted")
      expect(parsed_html.text).not_to match(/Originally\s+Accepted/)

      element = html_locator.element!("button[disabled]")
      expect(element.text.strip).to include("Stop")
      expect(element["aria-label"]).to eq("Stop Sharing")
      element = html_locator.element!("button[title='Share']")
      expect(element).not_to have_html_attribute(disabled: true)
    end
  end
end
