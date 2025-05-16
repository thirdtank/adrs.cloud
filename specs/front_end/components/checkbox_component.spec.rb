require "spec_helper"
RSpec.describe CheckboxComponent do
  context "when there are server-side constraint violations" do
    it "renders ther server-side constraint violations" do
      form = Class.new(Brut::FrontEnd::Form) {
        input :foo, type: :checkbox
      }.new
      form.server_side_constraint_violation(input_name: "foo", key: :required)
      component = described_class.new(
        label: "The Foo?",
        form: form,
        input_name: :foo,
      )

      html = generate_and_parse(component)
      expect(html.name).to eq("label")
      expect(html.text).to include("The Foo?")
      checkbox = html.css("input[type=checkbox]").first
      expect(checkbox).not_to eq(nil)
      expect(checkbox[:value]).to eq("true")
      violations = html.css("brut-cv-messages[input-name='foo'] brut-cv")
      expect(violations.size).to eq(1)

      expect(violations[0]).to have_html_attribute("server-side")
      expect(violations[0].text.strip).to eq("this field is required")
    end
  end
  context "when there are no server-side constraint violations" do
    it "renders the label and checkbox" do
      form = Class.new(Brut::FrontEnd::Form) {
        input :foo, type: :checkbox
      }.new
      component = described_class.new(
        label: "The Foo?",
        form: form,
        input_name: :foo,
      )

      html = generate_and_parse(component)
      expect(html.name).to eq("label")
      expect(html.text).to include("The Foo?")
      checkbox = html.css("input[type=checkbox]").first
      expect(checkbox).not_to eq(nil)
      expect(checkbox[:value]).to eq("true")
      violations = html.css("brut-cv")
      expect(violations.size).to eq(0)
    end
  end
end
