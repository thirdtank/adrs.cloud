require "spec_helper"

RSpec.describe Adrs::FormComponent, component: true do
  context "ADR has been saved" do
    it "renders accept and reject buttons and uses an ajax submit button" do
      adr = create(:adr)
      form = EditDraftAdrWithExternalIdForm.new(params: { title: adr.title })
      component = described_class.new(form,action: :edit, external_id: adr.external_id)

      parsed_html = render_and_parse(component)

      expect(parsed_html.css("button[title='Reject ADR']").length).to eq(1)
      expect(parsed_html.css("button[title='Accept ADR']").length).to eq(1)
      expect(parsed_html.css("brut-ajax-submit button[title='Update Draft']").length).to eq(1)
    end
  end
  context "ADR has not been saved" do
    context "saving new" do
      it "has no accept or reject buttons, no ajax submit" do
        form = NewDraftAdrForm.new
        component = described_class.new(form,action: :new)

        parsed_html = render_and_parse(component)

        expect(parsed_html.css("button[title='Reject ADR']").length).to eq(0)
        expect(parsed_html.css("button[title='Accept ADR']").length).to eq(0)
        expect(parsed_html.css("brut-ajax-submit").length).to           eq(0)
        expect(parsed_html.css("button[title='Save Draft']").length).to eq(1)
      end
    end
    context "saving a replacement" do
      it "has no accept or reject buttons, no ajax submit" do
        replaced_adr_external_id = "some-adr-id"
        form = NewDraftAdrForm.new(params: { replaced_adr_external_id: replaced_adr_external_id })
        component = described_class.new(form,action: :replace)

        parsed_html = render_and_parse(component)

        expect(parsed_html.css("button[title='Reject ADR']").length).to eq(0)
        expect(parsed_html.css("button[title='Accept ADR']").length).to eq(0)
        expect(parsed_html.css("brut-ajax-submit").length).to           eq(0)
        expect(parsed_html.css("button[title='Save Replacement Draft']").length).to eq(1)
        expect(parsed_html.css("input[type='hidden'][name='replaced_adr_external_id']")).to have_html_attribute(value: replaced_adr_external_id)
      end
    end
    context "saving a refinement" do
      it "has no accept or reject buttons, no ajax submit" do
        refines_adr_external_id = "some-adr-id"
        form = NewDraftAdrForm.new(params: { refines_adr_external_id: refines_adr_external_id })
        component = described_class.new(form,action: :refine)

        parsed_html = render_and_parse(component)

        expect(parsed_html.css("button[title='Reject ADR']").length).to eq(0)
        expect(parsed_html.css("button[title='Accept ADR']").length).to eq(0)
        expect(parsed_html.css("brut-ajax-submit").length).to           eq(0)
        expect(parsed_html.css("button[title='Save Refining Draft']").length).to eq(1)
        expect(parsed_html.css("input[type='hidden'][name='refines_adr_external_id']")).to have_html_attribute(value: refines_adr_external_id)
      end
    end
  end

end
