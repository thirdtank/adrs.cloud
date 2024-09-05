require "spec_helper"
require "front_end/pages/adrs_page"

RSpec.describe AdrsPage do
  context "no adrs" do
    it "does not show any tables" do
      account = create(:account)
      page = described_class.new(account: account, flash: empty_flash)
      rendered_html = render_and_parse(page)
      expect(rendered_html.css("table").length).to eq(0)
      aggregate_failures do
        expect(rendered_html.text).to include("None Drafted")
        expect(rendered_html.text).to include("None Accepted")
        expect(rendered_html.text).to include("None Rejected")
        expect(rendered_html.text).to include("None Replaced")
      end
    end
  end
  context "flash info message" do
    it "shows the info message, translated" do
      account = create(:account)
      page = described_class.new(account: account, flash: flash_from(notice: :adr_created))
      info_message = page.t(:adr_created)
      rendered_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(rendered_html)
      aside = html_locator.element!("aside[role='status']")
      expect(aside.text.to_s.strip).to eq(info_message)
    end
  end
  context "showing all ADRs" do
    context "drafts" do
      it "shows the drafts table" do
        account = create(:account)
        adrs = [
          create(:adr, account: account),
          create(:adr, account: account),
          create(:adr, account: account)
        ]
        page = described_class.new(account: account, flash: empty_flash)
        rendered_html = render_and_parse(page)
        expect(rendered_html.text).not_to include("None Drafted")
        html_locator = Support::HtmlLocator.new(rendered_html)
        table = html_locator.table_captioned("Draft ADRs")
        rows = table.css("tbody tr")
        expect(rows.length).to eq(adrs.length + 1)
        expect(rows[adrs.length].text).to include("Add a new one")
      end
    end
    context "accepted adrs" do
      it "shows the accepted table" do
        account = create(:account)
        adrs = [
          create(:adr, :accepted, account: account),
          create(:adr, :accepted, account: account),
          create(:adr, :accepted, account: account)
        ]
        page = described_class.new(account: account, flash: empty_flash)
        rendered_html = render_and_parse(page)
        expect(rendered_html.text).not_to include("None Accepted")
        html_locator = Support::HtmlLocator.new(rendered_html)
        table = html_locator.table_captioned("Accepted ADRs")
        rows = table.css("tbody tr")
        expect(rows.length).to eq(adrs.length)
      end
    end
    context "rejected adrs" do
      it "shows the rejected table" do
        account = create(:account)
        adrs = [
          create(:adr, account: account, rejected_at: Time.now),
          create(:adr, account: account, rejected_at: Time.now),
          create(:adr, account: account, rejected_at: Time.now)
        ]
        page = described_class.new(account: account, flash: empty_flash)
        rendered_html = render_and_parse(page)
        expect(rendered_html.text).not_to include("None Rejected")
        html_locator = Support::HtmlLocator.new(rendered_html)
        table = html_locator.table_captioned("Rejected ADRs")
        rows = table.css("tbody tr")
        expect(rows.length).to eq(adrs.length)
      end
    end
    context "replaced adrs" do
      it "shows the replaced table" do
        account = create(:account)
        adrs = [
          create(:adr, :accepted, account: account, replaced_by_adr_id: create(:adr, :accepted, account: account).id),
          create(:adr, :accepted, account: account, replaced_by_adr_id: create(:adr, :accepted, account: account).id),
          create(:adr, :accepted, account: account, replaced_by_adr_id: create(:adr, :accepted, account: account).id),
        ]
        page = described_class.new(account: account, flash: empty_flash)
        rendered_html = render_and_parse(page)
        expect(rendered_html.text).not_to include("None Replaced")
        html_locator = Support::HtmlLocator.new(rendered_html)
        table = html_locator.table_captioned("Replaced ADRs")
        rows = table.css("tbody tr")
        expect(rows.length).to eq(adrs.length)
      end
    end
  end
  context "showing only ADRs with a given tag" do
    context "drafts" do
      it "shows the drafts table" do
        account = create(:account)
        adrs = [
          create(:adr, account: account, tags: [ "foo", "bar" ]),
          create(:adr, account: account, tags: [ "foo", "bar" ]),
          create(:adr, account: account, tags: [ "quux", "bar" ])
        ]
        page = described_class.new(account: account, flash: empty_flash, tag: "foo")
        rendered_html = render_and_parse(page)
        expect(rendered_html.text).not_to include("None Drafted")
        html_locator = Support::HtmlLocator.new(rendered_html)
        table = html_locator.table_captioned("Draft ADRs")
        rows = table.css("tbody tr")
        expect(rows.any? { |row| row.text.include?(adrs[0].title) }).to eq(true)
        expect(rows.any? { |row| row.text.include?(adrs[1].title) }).to eq(true)
        expect(rows.any? { |row| row.text.include?(adrs[2].title) }).to eq(false)
      end
    end
    context "accepted adrs" do
      it "shows the accepted table" do
        account = create(:account)
        adrs = [
          create(:adr, :accepted, account: account, tags: [ "foo", "bar" ]),
          create(:adr, :accepted, account: account, tags: [ "foo", "bar" ]),
          create(:adr, :accepted, account: account, tags: [ "quux", "bar" ])
        ]
        page = described_class.new(account: account, flash: empty_flash, tag: "foo")
        rendered_html = render_and_parse(page)
        expect(rendered_html.text).not_to include("None Accepted")
        html_locator = Support::HtmlLocator.new(rendered_html)
        table = html_locator.table_captioned("Accepted ADRs")
        rows = table.css("tbody tr")
        expect(rows.length).to eq(2)
        expect(rows.any? { |row| row.text.include?(adrs[0].title) }).to eq(true)
        expect(rows.any? { |row| row.text.include?(adrs[1].title) }).to eq(true)
        expect(rows.any? { |row| row.text.include?(adrs[2].title) }).to eq(false)
      end
    end
    context "rejected adrs" do
      it "does not show rejected adrs" do
        account = create(:account)
        adrs = [
          create(:adr, account: account, rejected_at: Time.now, tags: [ "foo", "bar" ]),
          create(:adr, account: account, rejected_at: Time.now, tags: [ "foo", "bar" ]),
          create(:adr, account: account, rejected_at: Time.now, tags: [ "quux", "bar" ])
        ]
        page = described_class.new(account: account, flash: empty_flash, tag: "foo")
        rendered_html = render_and_parse(page)
        expect(rendered_html.text).not_to include(adrs[0].title)
        expect(rendered_html.text).not_to include(adrs[1].title)
        expect(rendered_html.text).not_to include(adrs[2].title)
      end
    end
    context "replaced adrs" do
      it "shows the replaced table" do
        account = create(:account)
        adrs = [
          create(:adr, :accepted, tags: [ "foo", "bar" ], account: account, replaced_by_adr_id: create(:adr, :accepted, account: account).id),
          create(:adr, :accepted, tags: [ "foo", "bar" ], account: account, replaced_by_adr_id: create(:adr, :accepted, account: account).id),
          create(:adr, :accepted, tags: [ "quux", "bar" ], account: account, replaced_by_adr_id: create(:adr, :accepted, account: account).id),
        ]
        page = described_class.new(account: account, flash: empty_flash, tag: "foo")
        rendered_html = render_and_parse(page)
        expect(rendered_html.text).not_to include(adrs[0].title)
        expect(rendered_html.text).not_to include(adrs[1].title)
        expect(rendered_html.text).not_to include(adrs[2].title)
      end
    end
  end
end
