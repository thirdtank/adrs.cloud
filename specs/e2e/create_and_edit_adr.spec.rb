require "spec_helper"

RSpec.describe "Create and Edit an ADR" do
  include Support::E2E::Login
  it "can create and edit an ADR" do
    account = create(:account)
    other_project1 = create(:project, account: account)
    other_project2 = create(:project, account: account, name: "zzz_lastone")
    login(page:,account:)

    link = page.locator("a[href='#{NewDraftAdrPage.routing}']")
    link.click

    submit_button = page.locator("form button[title='Save Draft']")

    submit_button.click

    title_field = page.locator("label", has: page.locator("input[name='title']"))
    expect(title_field).to have_text("This field is required")

    title_field.fill("SHORT")
    submit_button.click

    error = page.locator("[role=alert]")
    expect(error).to have_text("ADR cannot be created. See below.")
    expect(title_field).to have_text("This field must have at least 2 words")

    title_field.fill("Proper Title")
    project_selector = page.locator("select[name='project_external_id']")
    project_selector.select_option(label: other_project2.name)
    submit_button.click

    expect(page).to be_page_for(EditDraftAdrByExternalIdPage)
    project_selector = page.locator("select[name='project_external_id']")
    expect(project_selector).to have_value(other_project2.external_id)

    info = page.locator("[role=status]")
    expect(info).to have_text("ADR Created")

    back_link = page.locator("a", hasText: "Back")
    back_link.click

    table = page.locator("table", has: page.locator("caption", hasText: "Draft ADRs"))
    row = table.locator("tr[title='Proper Title']")

    expect(row).to have_text("Proper Title")
    expect(row).to have_text(other_project2.name)
  end

end
