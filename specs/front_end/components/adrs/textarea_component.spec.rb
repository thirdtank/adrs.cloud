require "spec_helper"
RSpec.describe Adrs::TextareaComponent do
  context "constraint violations" do
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
        context: "Some context",
      )

      html = render_and_parse(component)
      violations = html.css("brut-cv-messages[input-name='foo'] brut-cv")
      expect(violations.size).to eq(1)

      expect(violations[0]).to have_html_attribute("server-side")
      expect(violations[0].text.strip).to eq("this field must have at least 2 words")
    end
  end
end
