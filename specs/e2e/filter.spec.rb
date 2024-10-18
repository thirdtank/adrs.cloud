require "spec_helper"

RSpec.describe "Filer ADRs" do
  include Support::E2E::Login
  it "can search by projects and/or tags" do
    account = create(:account)
    projects = [
      account.projects.first,
      create(:project,account:),
      create(:project,account:),
    ]
    adrs = [
      create(:adr, :accepted, account:, project: projects[1], tags: [ "foo", "bar" ]),
      create(:adr, :accepted, account:, project: projects[1], tags: [ "bar" ]),
      create(:adr, :accepted, account:, project: projects[2], tags: [ "foo", ]),
    ]

    login(page:,account:)

    accepted_tab = page.locator("#accepted-tab")
    accepted_tab.click

    accepted_panel = page.locator("#accepted-panel")

    confidence_check do
      table = accepted_panel.locator("table")
      expect(table).to have_text(adrs[0].title)
      expect(table).to have_text(adrs[1].title)
      expect(table).to have_text(adrs[2].title)
    end

    form = page.locator("form")
    project_select = form.locator("select[name='project_external_id']")
    project_select.select_option(label: projects[1].name)

    button = form.locator("button")
    button.click

    accepted_tab = page.locator("#accepted-tab")
    accepted_panel = page.locator("#accepted-panel")
    h2 = accepted_panel.locator("h2")
    expect(h2).to have_text(projects[1].name)

    table = accepted_panel.locator("table")
    expect(table.locator("tbody tr").count).to eq(2)
    expect(table).to have_text(adrs[0].title)
    expect(table).to have_text(adrs[1].title)

    form = page.locator("form")
    tag_field = form.locator("input[name='tag']")
    tag_field.fill("foo")

    button = form.locator("button")
    button.click

    accepted_tab = page.locator("#accepted-tab")
    accepted_panel = page.locator("#accepted-panel")
    h2 = accepted_panel.locator("h2")
    expect(h2).to have_text(projects[1].name)
    expect(h2).to have_text("foo")

    table = accepted_panel.locator("table")
    expect(table.locator("tbody tr").count).to eq(1)
    expect(table).to have_text(adrs[0].title)

    form = page.locator("form")
    project_select = form.locator("select[name='project_external_id']")
    project_select.select_option(label: "All")

    button = form.locator("button")
    button.click

    accepted_tab = page.locator("#accepted-tab")
    accepted_panel = page.locator("#accepted-panel")
    h2 = accepted_panel.locator("h2")
    expect(h2).to have_text("foo")

    table = accepted_panel.locator("table")
    expect(table.locator("tbody tr").count).to eq(2)
    expect(table).to have_text(adrs[0].title)
    expect(table).to have_text(adrs[2].title)
  end

end
