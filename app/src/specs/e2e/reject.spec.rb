require "spec_helper"

RSpec.describe "Reject an ADR" do
  it "can add and remove tags" do
    account = create(:account)
    adr = create(:adr, account: account)

    page.goto("/")
    button = page.locator("form[action='/auth/developer'] button")
    button.click

    field = page.locator("input[name=email]")
    field.fill(account.email)
    button = page.locator("form button")
    button.click

    expect(page.locator("h1")).to have_text("ADRs")

    link = page.locator("a[href='#{EditDraftAdrByExternalIdPage.routing(external_id: adr.external_id)}']")
    link.click

    reject_button = page.locator("button[formaction='#{RejectedAdrsWithExternalIdHandler.routing(external_id: adr.external_id)}']")
    reject_button.click

    nevermind_button = page.locator("brut-confirmation-dialog button[value='cancel']")
    nevermind_button.click

    reject_button.click

    confirm_button = page.locator("brut-confirmation-dialog button[value='ok']")
    confirm_button.click

    expect(page.locator("h1")).to have_text("ADRs")

    details = page.locator("summary", hasText: "View Replaced and Rejected ADRs")
    details.click

    table = page.locator("details table", has: page.locator("caption", hasText: "Rejected ADRs"))

    expect(table).to have_text(adr.title)
  end

end
