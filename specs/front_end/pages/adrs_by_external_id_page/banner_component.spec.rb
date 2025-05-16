require "spec_helper"

RSpec.describe AdrsByExternalIdPage::BannerComponent do
  it "uses the yielded block" do
    component = described_class.new(color: "", background_color: "")
    parsed_html = generate_and_parse(component) do
      "<p>block!</p>"
    end

    p = parsed_html.css("p")[0]
    expect(p).not_to eq(nil)
    expect(p.text).to eq("block!")
  end
  it "uses the timestamp and i18n key when no block given" do
    now = Time.now
    component = described_class.new(timestamp: now, i18n_key: :accepted, color: "", background_color: "")
    parsed_html = generate_and_parse(component)

    time = parsed_html.css("time")[0]
    expect(time).not_to eq(nil)
    expect(time).to have_html_attribute(datetime: now.strftime("%Y-%m-%d %H:%M:%S.%6N %Z"))
  end
end
