require "spec_helper"

RSpec.describe "Create and Edit an ADR" do
  include Support::E2E::Login
  it "can create and edit an ADR" do
    account = create(:account)
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
    submit_button.click

    info = page.locator("[role=status]")
    expect(info).to have_text("ADR Created")

    back_link = page.get_by_text("Back")
    back_link.click

    table = page.locator("table", has: page.locator("caption", hasText: "Draft ADRs"))

    expect(table).to have_text("Proper Title")
  end

end
