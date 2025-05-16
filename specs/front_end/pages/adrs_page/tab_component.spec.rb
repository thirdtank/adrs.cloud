require "spec_helper"

RSpec.describe AdrsPage::TabComponent do
  it "renders aria-compliant tabs" do
    component = described_class.new(tabs: [ :accepted, :drafts ], selected_tab: :accepted, css_class: "foo")

    parsed_html = generate_and_parse(component)

    expect(parsed_html.css("#accepted-tab").length).to eq(1)
    tab = parsed_html.css("#accepted-tab")[0]
    expect(tab).to have_html_attribute(role: :tab)
    expect(tab).to have_html_attribute("aria-selected" => "true")
    expect(tab).to have_html_attribute("tabindex" => "0")
    expect(tab).to have_html_attribute("aria-controls" => "accepted-panel")

    expect(parsed_html.css("#drafts-tab").length).to eq(1)
    tab = parsed_html.css("#drafts-tab")[0]
    expect(tab).to have_html_attribute(role: :tab)
    expect(tab).to have_html_attribute("aria-selected" => "false")
    expect(tab).to have_html_attribute("tabindex" => "-1")
    expect(tab).to have_html_attribute("aria-controls" => "drafts-panel")
  end
end
