require "spec_helper"

RSpec.describe "Accept an ADR" do
  it "can add and remove tags" do
    account = create(:account)
    adr = create(:adr, :accepted,
                 account: account,
                 accepted_at: nil, # but not accepted
                 context: nil)     # and without a context, which we'll fill in an expected to be saved

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

    accept_button = page.locator("button[formaction='#{AcceptedAdrsWithExternalIdForm.routing(external_id: adr.external_id)}']")
    accept_button.click

    nevermind_button = page.locator("brut-confirmation-dialog button[value='cancel']")
    nevermind_button.click

    accept_button.click

    confirm_button = page.locator("brut-confirmation-dialog button[value='ok']")
    confirm_button.click

    context_field = page.locator("label", has: page.locator("textarea[name='context']"))
    expect(context_field).to have_text("This field is required")

    context_field.locator("textarea").fill("This is some context")

    accept_button = page.locator("button[formaction='#{AcceptedAdrsWithExternalIdForm.routing(external_id: adr.external_id)}']")
    accept_button.click

    confirm_button = page.locator("brut-confirmation-dialog button[value='ok']")
    confirm_button.click

    expect(page.locator("h2")).to have_text(adr.title)
    expect(page.locator("section[aria-label='context']")).to   have_text("This is some context")
    expect(page.locator("section[aria-label='facing']")).to    have_text(adr.facing)
    expect(page.locator("section[aria-label='decision']")).to  have_text(adr.decision)
    expect(page.locator("section[aria-label='neglected']")).to have_text(adr.neglected)
    expect(page.locator("section[aria-label='achieve']")).to   have_text(adr.achieve)
    expect(page.locator("section[aria-label='accepting']")).to have_text(adr.accepting)
    expect(page.locator("section[aria-label='because']")).to   have_text(adr.because)
    adr.reload
    expect(page.locator("h3", hasText: 'Accepted')).to have_text(adr.accepted_at.to_s)
  end

end
