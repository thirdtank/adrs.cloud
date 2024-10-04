require "spec_helper"

RSpec.describe AnnouncementBannerComponent do
  it "shows the alert even if there is a notice" do
    flash = empty_flash
    flash.alert = "diagnostics.simple1"
    flash.notice = "diagnostics.simple2"
    component = described_class.new(flash:)

    parsed_html = render_and_parse(component)

    expect(parsed_html.text).to include("SIMPLE1")
    expect(parsed_html.text).not_to include("SIMPLE2")
  end

  it "shows a site announcement" do
    component = described_class.new(flash:empty_flash,site_announcement:"diagnostics.simple1")

    parsed_html = render_and_parse(component)

    expect(parsed_html.text).to include("SIMPLE1")
  end
  it "shows a fallback announcement by default" do
    component = described_class.new(flash:empty_flash)

    parsed_html = render_and_parse(component)

    expect(parsed_html.text).to include("System is working properly")
  end
end
