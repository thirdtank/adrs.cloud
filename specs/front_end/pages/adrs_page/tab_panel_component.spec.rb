require "spec_helper"

RSpec.describe AdrsPage::TabPanelComponent do
  describe "tag and project in title" do
    it "includes the project in the h2" do
      adr = create(:adr, tags: [ "blah" ])

      component = described_class.new(adrs: [ adr ],
                                      tab: :drafts,
                                      columns: [ :title ],
                                      selected: false,
                                      tag: "blah",
                                      project: adr.project,
                                      action: :edit)

      parsed_html = generate_and_parse(component)
      h2 = parsed_html.css("h2")
      expect(h2.text).to include("blah")
      expect(h2.text).to include(adr.project.name)
    end
  end
  describe "actions" do
    it "uses the edit link for :edit" do
      adr = create(:adr)

      component = described_class.new(adrs: [ adr ],
                                      tab: :drafts,
                                      columns: [ :title ],
                                      selected: false,
                                      tag: nil,
                                      project: nil,
                                      action: :edit)

      parsed_html = generate_and_parse(component)
      links = parsed_html.css("a[href='#{EditDraftAdrByExternalIdPage.routing(external_id: adr.external_id)}']")
      expect(links.length).to eq(1)
    end

    it "uses the view link for :view" do
      adr = create(:adr)

      component = described_class.new(adrs: [ adr ],
                                      tab: :drafts,
                                      columns: [ :title ],
                                      selected: false,
                                      tag: nil,
                                      project: nil,
                                      action: :view)

      parsed_html = generate_and_parse(component)
      links = parsed_html.css("a[href='#{AdrsByExternalIdPage.routing(external_id: adr.external_id)}']")
      expect(links.length).to eq(1)
    end
  end
  describe "selected" do
    it "shows proper attributes when selected" do
      adr = create(:adr)

      component = described_class.new(adrs: [ adr ],
                                      tab: :drafts,
                                      columns: [ :title ],
                                      selected: true,
                                      tag: nil,
                                      project: nil,
                                      action: :view)
      parsed_html = generate_and_parse(component)
      expect(parsed_html).to have_html_attribute(role: :tabpanel)
      expect(parsed_html).not_to have_html_attribute(:hidden)
    end
    it "shows proper attributes when not selected" do
      adr = create(:adr)

      component = described_class.new(adrs: [ adr ],
                                      tab: :drafts,
                                      columns: [ :title ],
                                      selected: false,
                                      tag: nil,
                                      project: nil,
                                      action: :view)
      parsed_html = generate_and_parse(component)
      expect(parsed_html).to have_html_attribute(role: :tabpanel)
      expect(parsed_html).to have_html_attribute(:hidden)
    end
  end
  describe "column values" do
    it "shows the value as a string by default" do
      adr = create(:adr, context: "this is some context")

      component = described_class.new(adrs: [ adr ],
                                      tab: :drafts,
                                      columns: [ :context ],
                                      selected: false,
                                      tag: nil,
                                      project: nil,
                                      action: :view)

      parsed_html = generate_and_parse(component)

      tds = parsed_html.css("tbody tr td")
      expect(tds.length).to eq(2)
      expect(tds[0].text.strip).to eq(adr.context)
    end
    it "uses the title component for the title" do
      adr = create(:adr, tags: [ "foo", "bar" ])

      component = described_class.new(adrs: [ adr ],
                                      tab: :drafts,
                                      columns: [ :title ],
                                      selected: false,
                                      tag: nil,
                                      project: nil,
                                      action: :view)
      parsed_html = generate_and_parse(component)
      expect(parsed_html.text).to include("foo")
      expect(parsed_html.text).to include("bar")
      expect(parsed_html.text).to include(adr.title)
    end

    it "uses the project name for :project" do
      adr = create(:adr)

      component = described_class.new(adrs: [ adr ],
                                      tab: :drafts,
                                      columns: [ :project ],
                                      selected: false,
                                      tag: nil,
                                      project: nil,
                                      action: :view)
      parsed_html = generate_and_parse(component)
      expect(parsed_html.text).to include(adr.project.name)
    end

    it "formats a date using a <time>" do
      adr = create(:adr)

      component = described_class.new(adrs: [ adr ],
                                      tab: :drafts,
                                      columns: [ :created_at ],
                                      tag: nil,
                                      project: nil,
                                      selected: false,
                                      action: :view)

      parsed_html = generate_and_parse(component)

      tds = parsed_html.css("tbody tr td")
      expect(tds.length).to eq(2)
      time = tds[0].css("time")[0]
      expect(time).not_to eq(nil)
      expect(time).to have_html_attribute(datetime: adr.created_at.strftime("%Y-%m-%d %H:%M:%S.%6N %Z"))
    end
  end
end
