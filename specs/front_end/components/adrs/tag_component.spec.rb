require "spec_helper"

RSpec.describe Adrs::TagComponent, component: true do
  context "tag is 'shared'" do
    it "inlines an SVG icon" do
      component = described_class.new(tag: "shared")
      parsed_html = generate_and_parse(component)
      expect(parsed_html.css("svg").length).to eq(1)
    end
  end
  context "tag is not 'shared'" do
    it "has no icon" do
      component = described_class.new(tag: "not-shared")
      parsed_html = generate_and_parse(component)
      expect(parsed_html.css("svg").length).to eq(0)
    end
  end

end
