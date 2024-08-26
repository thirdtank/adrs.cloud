require "spec_helper"
require "front_end/pages/adrs_for_tag"

RSpec.describe Pages::AdrsForTag do
  context "no accepted or draft adrs" do
    it "does not show any tables" do

      account = create(:account)
      adrs = [
        create(:adr, account: account, rejected_at: Time.now),
        create(:adr, account: account, rejected_at: Time.now),
        create(:adr, account: account, rejected_at: Time.now),
      ]

      page = described_class.new(adrs: adrs, tag: "foo")
      rendered_html = render_and_parse(page)
      expect(rendered_html.css("table").length).to eq(0)
      aggregate_failures do
        expect(rendered_html.text).to include("None Drafted with tag")
        expect(rendered_html.text).to include("None Accepted with tag")
      end
    end
  end
  context "accepted adrs" do
    it "shows the accepted table" do
      account = create(:account)
      adrs = [
        create(:adr, :accepted, account: account),
        create(:adr, :accepted, account: account),
        create(:adr, :accepted, account: account),
      ]
      page = described_class.new(adrs: adrs, tag: "foo")
      rendered_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(rendered_html)
      expect(rendered_html.text).not_to include("None Accepted with tag 'foo'")
      table = html_locator.table_captioned("Accepted ADRs")
      rows = table.css("tbody tr")
      expect(rows.length).to eq(adrs.length)
    end
  end
  context "draft adrs" do
    it "shows the draft table" do
      account = create(:account)
      adrs = [
        create(:adr, account: account),
        create(:adr, account: account),
        create(:adr, account: account),
      ]
      page = described_class.new(adrs: adrs, tag: "foo")
      rendered_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(rendered_html)
      expect(rendered_html.text).not_to include("None Drafted with tag 'foo'")
      table = html_locator.table_captioned("Draft ADRs")
      rows = table.css("tbody tr")
      expect(rows.length).to eq(adrs.length)
    end
  end
end
