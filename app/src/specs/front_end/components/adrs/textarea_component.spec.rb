require "spec_helper"
RSpec.describe Adrs::TextareaComponent do
  context "constraint violations" do
    it "renders server-side constraint violations container and a client-side one" do
      form = Class.new(Brut::FrontEnd::Form) {
        input :foo
      }.new
      component = described_class.new(
        label: "The Foo Field",
        form: form,
        input_name: :foo,
        prefix: "context",
      )

      html = render_and_parse(component)
      violations = html.css("brut-constraint-violation-messages")
      expect(violations.size).to eq(2)

      expect(violations[0]).not_to have_html_attribute("server-side")
      expect(violations[0]).not_to have_html_attribute("input-name")

      expect(violations[1]).to have_html_attribute("server-side")
      expect(violations[1]).to have_html_attribute("input-name" => "foo")
    end
    it "renders only server-side constraint violations" do
      form = Class.new(Brut::FrontEnd::Form) {
        input :foo, required: true
      }.new

      form.server_side_constraint_violation(input_name: "foo", key: :not_enough_words, context: { minwords: 2 })
      expect(form.constraint_violations?).to eq(true)

      component = described_class.new(
        label: "The Foo Field",
        form: form,
        input_name: :foo,
        prefix: "context",
      )

      html = render_and_parse(component)
      violations = html.css("brut-constraint-violation-messages")
      expect(violations.size).to eq(2)

      expect(violations[0]).not_to have_html_attribute("server-side")
      expect(violations[0]).not_to have_html_attribute("input-name")
      expect(violations[0].css("brut-constraint-violation-message").size).to eq(0)

      expect(violations[1]).to have_html_attribute("server-side")
      expect(violations[1]).to have_html_attribute("input-name" => "foo")
      expect(violations[1].css("brut-constraint-violation-message").size).to eq(1),violations[1].to_html
      message = violations[1].css("brut-constraint-violation-message")[0]
      expect(message.text.strip).to eq("This field must have at least 2 words")
    end
  end
end
