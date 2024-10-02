require "spec_helper"
require "front_end/pages/adrs_page"

RSpec.describe AdrsPage do
  RSpec::Matchers.define :have_selected_tab do |tab_element_id|
    match do |rendered_html|
      result, info = analyze(rendered_html,tab_element_id)
      if result == :error
        throw info
      end
      result == :match
    end

    failure_message do |rendered_html|
      result, info = analyze(rendered_html,tab_element_id)
      if result == :error
        throw info
      end
      if result == :no_match
        errors = []
        if !info[:tab_selected]
          errors << "Tab with id #{tab_element_id} was not aria-selected (#{info[:tab].to_html}"
        end
        if !info[:proper_tabindex]
          errors << "Tab with id #{tab_element_id} did not have a tabindex of '0' (#{info[:tab].to_html}"
        end
        if info[:hidden_panels].any?
          errors << "Tab with id #{tab_element_id} referred to panels that were hidden: #{hidden_panels.map(&:to_html)}"
        end
        errors.join(", ")
      end
    end

    failure_message_when_negated do |rendered_html|
      result, info = analyze(rendered_html,tab_element_id)
      if result == :error
        throw info
      end
      "#{tab_element_id} had attributes indicating it's selected, when it was not expected to be:\n#{info[:tab].to_html}\n\n#{info[:panels].map(&:to_html)}"
    end

    def analyze(rendered_html,tab_element_id)
      locator = Support::HtmlLocator.new(rendered_html)
      tab = locator.element("[id=#{tab_element_id}]")
      if !tab
        return [ :error, "Could not find tab with id tab_element_id" ]
      end
      panel_id = tab["aria-controls"].to_s.strip
      if panel_id == ""
        return [ :error, "tab with id #{tab_element_id} does not have a value for 'aria-controls': #{tab.to_html}" ]
      end
      panels = panel_id.split(/\s+/).map { |id|
        [ id, locator.element("[id=#{id}]") ]
      }
      missing_panels = panels.select { |(_,panel)| panel.nil? }.map { |(id,_)| }
      if missing_panels.any?
        return [ :error, "tab with id #{tab_element_id} referenced an element with these ids, none of which exist: #{missing_panels.join(', ')}" ]
      end

      tab_selected    = tab["aria-selected"] == "true"
      proper_tabindex = tab["tabindex"] == "0"
      hidden_panels   = panels.select { |(id,panel)|
        panel["hidden"] != nil
      }

      if tab_selected && proper_tabindex && hidden_panels.length == 0
        [ :match, { tab: tab, panels: panels.map { |(_,panel)| panel } } ]
      else
        [ :no_match, { tab: tab, tab_selected: tab_selected, proper_tabindex: proper_tabindex, hidden_panels: hidden_panels.map { |(_,panel)| panel } } ]
      end

    end

  end
  context "no adrs" do
    it "does not show any tables" do
      authenticated_account = create(:authenticated_account)

      page = described_class.new(authenticated_account:, flash: empty_flash)

      rendered_html = render_and_parse(page)
      locator = Support::HtmlLocator.new(rendered_html)
      aggregate_failures do
        expect(locator.element("[id=drafts-panel]").text).to include("None")
        expect(locator.element("[id=drafts-panel] table")).to eq(nil)

        expect(locator.element("[id=accepted-panel]").text).to include("None")
        expect(locator.element("[id=accepted-panel] table")).to eq(nil)

        expect(locator.element("[id=rejected-panel]").text).to include("None")
        expect(locator.element("[id=rejected-panel] table")).to eq(nil)

        expect(locator.element("[id=replaced-panel]").text).to include("None")
        expect(locator.element("[id=replaced-panel] table")).to eq(nil)

      end
    end
  end
  context "flash info message" do
    it "shows the info message, translated" do
      authenticated_account = create(:authenticated_account)

      page = described_class.new(authenticated_account:, flash: flash_from(notice: :adr_created))

      info_message = page.t(:adr_created)
      rendered_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(rendered_html)
      aside = html_locator.element!("[role='status']")
      expect(aside.text.to_s.strip).to eq(info_message)
    end
  end
  context "tabs" do
    it "shows the accepted tab when no tab= query string is given" do
      authenticated_account = create(:authenticated_account)

      create(:adr, account: authenticated_account.account)
      create(:adr, :accepted, account: authenticated_account.account)
      create(:adr, :rejected, account: authenticated_account.account)
      create(:adr, :accepted, account: authenticated_account.account,
             replaced_by_adr: create(:adr, :accepted, account: authenticated_account.account))

      page = described_class.new(authenticated_account:, flash: empty_flash)
      rendered_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(rendered_html)

      expect(rendered_html).to     have_selected_tab("accepted-tab")
      expect(rendered_html).not_to have_selected_tab("drafts-tab")
      expect(rendered_html).not_to have_selected_tab("replaced-tab")
      expect(rendered_html).not_to have_selected_tab("rejected-tab")
    end
    it "shows the accepted tab when tab=accepted query string is given" do
      authenticated_account = create(:authenticated_account)

      create(:adr, account: authenticated_account.account)
      create(:adr, :accepted, account: authenticated_account.account)
      create(:adr, :rejected, account: authenticated_account.account)
      create(:adr, :accepted, account: authenticated_account.account,
             replaced_by_adr: create(:adr, :accepted, account: authenticated_account.account))

      page = described_class.new(authenticated_account:, flash: empty_flash, tab: "accepted")
      rendered_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(rendered_html)

      expect(rendered_html).to     have_selected_tab("accepted-tab")
      expect(rendered_html).not_to have_selected_tab("drafts-tab")
      expect(rendered_html).not_to have_selected_tab("replaced-tab")
      expect(rendered_html).not_to have_selected_tab("rejected-tab")
    end
    it "shows the drafts tab when tab=drafts query string is given" do
      authenticated_account = create(:authenticated_account)

      create(:adr, account: authenticated_account.account)
      create(:adr, :accepted, account: authenticated_account.account)
      create(:adr, :rejected, account: authenticated_account.account)
      create(:adr, :accepted, account: authenticated_account.account,
             replaced_by_adr: create(:adr, :accepted, account: authenticated_account.account))

      page = described_class.new(authenticated_account:, flash: empty_flash, tab: "drafts")
      rendered_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(rendered_html)

      expect(rendered_html).not_to have_selected_tab("accepted-tab")
      expect(rendered_html).to     have_selected_tab("drafts-tab")
      expect(rendered_html).not_to have_selected_tab("replaced-tab")
      expect(rendered_html).not_to have_selected_tab("rejected-tab")
    end
    it "shows the replaced tab when tab=replaced query string is given" do
      authenticated_account = create(:authenticated_account)

      create(:adr, account: authenticated_account.account)
      create(:adr, :accepted, account: authenticated_account.account)
      create(:adr, :rejected, account: authenticated_account.account)
      create(:adr, :accepted, account: authenticated_account.account,
             replaced_by_adr: create(:adr, :accepted, account: authenticated_account.account))

      page = described_class.new(authenticated_account:, flash: empty_flash, tab: "replaced")
      rendered_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(rendered_html)

      expect(rendered_html).not_to have_selected_tab("accepted-tab")
      expect(rendered_html).not_to have_selected_tab("drafts-tab")
      expect(rendered_html).to     have_selected_tab("replaced-tab")
      expect(rendered_html).not_to have_selected_tab("rejected-tab")
    end
    it "shows the rejected tab when tab=rejected query string is given" do
      authenticated_account = create(:authenticated_account)

      create(:adr, account: authenticated_account.account)
      create(:adr, :accepted, account: authenticated_account.account)
      create(:adr, :rejected, account: authenticated_account.account)
      create(:adr, :accepted, account: authenticated_account.account,
             replaced_by_adr: create(:adr, :accepted, account: authenticated_account.account))

      page = described_class.new(authenticated_account:, flash: empty_flash, tab: "rejected")
      rendered_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(rendered_html)

      expect(rendered_html).not_to have_selected_tab("accepted-tab")
      expect(rendered_html).not_to have_selected_tab("drafts-tab")
      expect(rendered_html).not_to have_selected_tab("replaced-tab")
      expect(rendered_html).to     have_selected_tab("rejected-tab")
    end
  end
  context "add new link" do
    context "user is entitled to add more ADRs" do
      it "shows the link" do
        authenticated_account = create(:authenticated_account)
        adrs                  = 3.times.map {
          create(:adr, account: authenticated_account.account)
        }

        page = described_class.new(authenticated_account:, flash: empty_flash)

        rendered_html = render_and_parse(page)
        html_locator = Support::HtmlLocator.new(rendered_html)
        side_nav = html_locator.element!("nav")
        expect(side_nav.css("a[href='#{NewDraftAdrPage.routing}']")).not_to eq(nil)
      end
    end
    context "user is not entitled to add more ADRs" do
      it "does not show the link" do
        authenticated_account = create(:authenticated_account)
        adrs                  = 3.times.map {
          create(:adr, account: authenticated_account.account)
        }
        authenticated_account.account.entitlement.update(max_non_rejected_adrs: adrs.length)

        page = described_class.new(authenticated_account:, flash: empty_flash)

        rendered_html = render_and_parse(page)
        html_locator = Support::HtmlLocator.new(rendered_html)
        side_nav = html_locator.element!("nav")
        expect(side_nav.css("a[href='#{NewDraftAdrPage.routing}']").length).to eq(0)
        expect(side_nav.text).to include("You&#39;ve reached your plan limit")
      end
    end
  end
  context "showing all ADRs in account" do
    context "drafts" do
      it "shows the drafts table" do
        authenticated_account = create(:authenticated_account)
        adrs                  = 3.times.map {
          create(:adr, account: authenticated_account.account)
        }

        page = described_class.new(authenticated_account:, flash: empty_flash)

        rendered_html = render_and_parse(page)
        html_locator = Support::HtmlLocator.new(rendered_html)
        table = html_locator.element!("[id=drafts-panel] table")
        rows = table.css("tbody tr")
        expect(rows.length).to eq(adrs.length)
      end
    end
    context "accepted adrs" do
      it "shows the accepted table" do
        authenticated_account = create(:authenticated_account)
        adrs                  = 3.times.map {
          create(:adr, :accepted, account: authenticated_account.account)
        }

        page = described_class.new(authenticated_account:, flash: empty_flash)

        rendered_html = render_and_parse(page)
        html_locator = Support::HtmlLocator.new(rendered_html)
        table = html_locator.element!("[id=accepted-panel] table")
        rows = table.css("tbody tr")
        expect(rows.length).to eq(adrs.length)
      end
    end
    context "rejected adrs" do
      it "shows the rejected table" do
        authenticated_account = create(:authenticated_account)
        adrs                  = 3.times.map {
          create(:adr, rejected_at: Time.now, account: authenticated_account.account)
        }

        page = described_class.new(authenticated_account:, flash: empty_flash)

        rendered_html = render_and_parse(page)
        html_locator = Support::HtmlLocator.new(rendered_html)
        table = html_locator.element!("[id=rejected-panel] table")
        rows = table.css("tbody tr")
        expect(rows.length).to eq(adrs.length)
      end
    end
    context "replaced adrs" do
      it "shows the replaced table" do
        authenticated_account = create(:authenticated_account)
        adrs = 3.times.map {
          create(:adr, :accepted,
                 account: authenticated_account.account,
                 replaced_by_adr_id: create(:adr, :accepted,
                                            account: authenticated_account.account).id)
        }

        page = described_class.new(authenticated_account:, flash: empty_flash)

        rendered_html = render_and_parse(page)
        html_locator = Support::HtmlLocator.new(rendered_html)
        table = html_locator.element!("[id=replaced-panel] table")
        rows = table.css("tbody tr")
        expect(rows.length).to eq(adrs.length)
      end
    end
  end
  context "showing only ADRs with a given tag" do
    context "drafts" do
      it "shows the drafts table" do
        authenticated_account = create(:authenticated_account)
        adrs                  = 3.times.map {
          create(:adr, account: authenticated_account.account, tags: [ "foo", "bar" ])
        }
        tagged_adr = create(:adr, account: authenticated_account.account, tags: [ "blah" ])

        page = described_class.new(authenticated_account:, flash: empty_flash, tag: "blah")

        rendered_html = render_and_parse(page)
        html_locator = Support::HtmlLocator.new(rendered_html)
        table = html_locator.element!("[id=drafts-panel] table")
        rows = table.css("tbody tr")
        expect(rows.length).to eq(1)
        expect(rows[0].text).to include(tagged_adr.title)
      end
    end
    context "accepted adrs" do
      it "shows the accepted table" do
        authenticated_account = create(:authenticated_account)
        adrs                  = 3.times.map {
          create(:adr, :accepted, account: authenticated_account.account, tags: [ "foo", "bar" ])
        }
        tagged_adr = create(:adr, :accepted, account: authenticated_account.account, tags: [ "blah" ])

        page = described_class.new(authenticated_account:, flash: empty_flash, tag: "blah")

        rendered_html = render_and_parse(page)
        html_locator = Support::HtmlLocator.new(rendered_html)
        table = html_locator.element!("[id=accepted-panel] table")
        rows = table.css("tbody tr")
        expect(rows.length).to eq(1)
        expect(rows[0].text).to include(tagged_adr.title)
      end
    end
    context "rejected adrs" do
      it "shows the rejected table" do
        authenticated_account = create(:authenticated_account)
        adrs                  = 3.times.map {
          create(:adr, rejected_at: Time.now, account: authenticated_account.account, tags: [ "foo", "bar" ])
        }
        tagged_adr = create(:adr, rejected_at: Time.now, account: authenticated_account.account, tags: [ "blah" ])

        page = described_class.new(authenticated_account:, flash: empty_flash, tag: "blah")

        rendered_html = render_and_parse(page)
        html_locator = Support::HtmlLocator.new(rendered_html)
        table = html_locator.element!("[id=rejected-panel] table")
        rows = table.css("tbody tr")
        expect(rows.length).to eq(1)
        expect(rows[0].text).to include(tagged_adr.title)
      end
    end
    context "replaced adrs" do
      it "shows the replaced table" do
        authenticated_account = create(:authenticated_account)
        adrs = 3.times.map {
          create(:adr, :accepted,
                 account: authenticated_account.account,
                 tags: [ "foo", "bar" ],
                 replaced_by_adr_id: create(:adr, :accepted,
                                            account: authenticated_account.account).id)
        }
        tagged_adr = create(:adr, :accepted,
                            account: authenticated_account.account,
                            tags: [ "blah" ],
                            replaced_by_adr_id: create(:adr, :accepted,
                                                       account: authenticated_account.account).id)

        page = described_class.new(authenticated_account:, flash: empty_flash, tag: "blah")

        rendered_html = render_and_parse(page)
        html_locator = Support::HtmlLocator.new(rendered_html)
        table = html_locator.element!("[id=replaced-panel] table")
        rows = table.css("tbody tr")
        expect(rows.length).to eq(1)
        expect(rows[0].text).to include(tagged_adr.title)
      end
    end
  end
end
