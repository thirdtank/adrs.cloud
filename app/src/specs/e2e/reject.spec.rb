require "spec_helper"

RSpec.describe "Reject an ADR" do
  include Support::E2E::Login
  it "can add and remove tags" do
    account = create(:account)
    adr = create(:adr, account: account, project: account.projects.first)
    login(page:,account:)

    drafts_tab = page.locator("#drafts-tab")
    drafts_tab.click

    link = page.locator("a[href='#{EditDraftAdrByExternalIdPage.routing(external_id: adr.external_id)}']")
    link.click

    reject_button = page.locator("button[formaction='#{RejectedAdrsWithExternalIdHandler.routing(external_id: adr.external_id)}']")
    reject_button.click

    nevermind_button = page.locator("brut-confirmation-dialog button[value='cancel']")
    nevermind_button.click

    reject_button.click

    confirm_button = page.locator("brut-confirmation-dialog button[value='ok']")
    confirm_button.click

    expect(page).to be_page_for(AdrsPage)

    rejected_tab = page.locator("#rejected-tab")
    rejected_tab.click

    table = page.locator("#rejected-panel table")

    expect(table).to have_text(adr.title)
  end

end
