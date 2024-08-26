require "spec_helper"
require "front_end/components/adrs/tag"

RSpec.describe Components::Adrs::Tag, component: true do
  context "tag is 'public'" do
    it "inlines an SVG icon" do
      component = described_class.new(tag: "public")
      parsed_html = render_and_parse(component)
      expect(parsed_html.css("svg").length).to eq(1)
    end
  end
  context "tag is not 'public'" do
    it "has no icon" do
      component = described_class.new(tag: "not-public")
      parsed_html = render_and_parse(component)
      expect(parsed_html.css("svg").length).to eq(0)
    end
  end

end
