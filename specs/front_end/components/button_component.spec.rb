require "spec_helper"
RSpec.describe ButtonComponent do
  context "title" do
    it "uses the disabled message as the title" do
      button = described_class.new(disabled: "not allowed", label: "Test")

      button_element = generate_and_parse(button)

      expect(button_element.name).to eq("button")
      expect(button_element).to have_html_attribute(title: "not allowed")
      expect(button_element).to have_html_attribute(:disabled)
    end
    it "uses the title as the title" do
      button = described_class.new(title: "does stuff", label: "Test")

      button_element = generate_and_parse(button)

      expect(button_element.name).to eq("button")
      expect(button_element).to have_html_attribute(title: "does stuff")
    end
    it "uses the label as the title" do
      button = described_class.new(label: "Test")

      button_element = generate_and_parse(button)

      expect(button_element.name).to eq("button")
      expect(button_element).to have_html_attribute(title: "Test")
    end
  end
  context "type" do
    it "shows a type attribute when given" do
      button = described_class.new(type: "reset", label: "Test")
      button_element = generate_and_parse(button)

      expect(button_element.name).to eq("button")
      expect(button_element).to have_html_attribute(type: "reset")
    end
    it "has no type attribute by default" do
      button = described_class.new(label: "Test")
      button_element = generate_and_parse(button)

      expect(button_element.name).to eq("button")
      expect(button_element).not_to have_html_attribute(:type)
    end
  end
  context "formaction" do
    it "shows a formaction attribute when given" do
      button = described_class.new(formaction: "/foo", label: "Test")
      button_element = generate_and_parse(button)

      expect(button_element.name).to eq("button")
      expect(button_element).to have_html_attribute(formaction: "/foo")
    end
    it "has no formaction attribute by default" do
      button = described_class.new(label: "Test")
      button_element = generate_and_parse(button)

      expect(button_element.name).to eq("button")
      expect(button_element).not_to have_html_attribute(:formaction)
    end
  end
  context "value" do
    it "shows a value attribute when given" do
      button = described_class.new(value: "foo", label: "Test")
      button_element = generate_and_parse(button)

      expect(button_element.name).to eq("button")
      expect(button_element).to have_html_attribute(value: "foo")
    end
    it "has no value attribute by default" do
      button = described_class.new(label: "Test")

      button_element = generate_and_parse(button)

      expect(button_element.name).to eq("button")
      expect(button_element).not_to have_html_attribute(:value)
    end
  end
  context "icon" do
    it "shows an icon when given" do
      button = described_class.new(icon: "key-icon", label: "Test")
      button_element = generate_and_parse(button)

      expect(button_element.name).to eq("button")

      svg = button_element.css("svg")
      expect(svg.length).to eq(1)
    end
    it "has no icon by default" do
      button = described_class.new(label: "Test")
      html = generate_and_parse(button)

      svg = html.css("button svg")
      expect(svg.length).to eq(0)
    end
  end
  context "confirmation" do
    it "surrounds the button in brut-confirmation if confirmation is requested" do
      button = described_class.new(confirm: "Are you sure?", label: "Test")
      html = generate_and_parse(button)
      locator = Support::HtmlLocator.new(html)

      button = locator.element!("button")
      expect(button.parent.name).to eq("brut-confirm-submit")
      expect(button.parent).to have_html_attribute(message: "Are you sure?")
    end
    it "does not use brut-confirmation by default" do
      button = described_class.new(label: "Test")
      html = generate_and_parse(button)

      expect(html.css("brut-confirm-submit").size).to eq(0)
    end
  end
end
