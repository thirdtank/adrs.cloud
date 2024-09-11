require "spec_helper"
RSpec.describe Admin::AccountsPage do
  it "should show no results for an empty search string" do
    page = described_class.new(search_string: "")

    rendered_html = render_and_parse(page)
    expect(rendered_html.text).to include("None Matched")
  end
  context "search string given" do
  it "should show results where emails contain the search string" do
    pat     = create(:account, email: "pat@example.com")
    chris   = create(:account, email: "chris@example.com")
    cameron = create(:account, email: "cameron@example.net")

    page = described_class.new(search_string: "example.com")

    rendered_html = render_and_parse(page)
    expect(rendered_html.text).to     include(pat.email)
    expect(rendered_html.text).to     include(chris.email)
    expect(rendered_html.text).not_to include(cameron.email)
  end
  it "should show none matched if there are no matching accounts" do
    create(:account)
    create(:account)
    page = described_class.new(search_string: "@gmail.com")

    rendered_html = render_and_parse(page)
    expect(rendered_html.text).to include("None Matched")
  end
  end
end
