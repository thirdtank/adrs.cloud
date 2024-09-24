require "spec_helper"

RSpec.describe "Refine an ADR" do
  include Support::E2E::Login
  it "can create an ADR that refines another one" do
    account = create(:account)
    accepted_adr = create(:adr, :accepted, account: account)
    login(page:,account:)

    view_link = page.locator("a[href='#{AdrsByExternalIdPage.routing(external_id: accepted_adr.external_id)}']")
    view_link.click

    refine_button = page.locator("button[formaction='#{RefinedAdrsWithExistingExternalIdHandler.routing(existing_external_id: accepted_adr.external_id)}']")
    refine_button.click

    expect(page).to be_page_for(NewDraftAdrPage)

    title = "A New ADR to clarify the old one"
    title_field = page.locator("label", has: page.locator("input[name='title']"))
    title_field.fill(title)

    submit_button = page.locator("form button[title='Save Draft']")
    submit_button.click

    expect(page).to be_page_for(EditDraftAdrByExternalIdPage)

    info = page.locator("aside[role=status]")
    expect(info).to have_text("ADR Created")
    expect(page.locator("h3")).to have_text("Refines “#{accepted_adr.title}”")

    page.locator("textarea[name='context']"  ) .fill("This is some context")
    page.locator("textarea[name='facing']"   ) .fill("This is some faing")
    page.locator("textarea[name='decision']" ) .fill("This is some decision")
    page.locator("textarea[name='neglected']") .fill("This is some neglected")
    page.locator("textarea[name='achieve']"  ) .fill("This is some achieve")
    page.locator("textarea[name='accepting']") .fill("This is some accepting")
    page.locator("textarea[name='because']"  ) .fill("This is some because")

    adr = DB::Adr.find!(title: title, refines_adr_id: accepted_adr.id)

    accept_button = page.locator("button[formaction='#{AcceptedAdrsWithExternalIdForm.routing(external_id: adr.external_id)}']")
    accept_button.click

    confirm_button = page.locator("brut-confirmation-dialog button[value='ok']")
    confirm_button.click

    expect(page).to be_page_for(AdrsByExternalIdPage)
    expect(page.locator("h3", hasText: "Accepted")).to have_text(adr.accepted_at.to_s)
    expect(page.locator("h3", hasText: "Refines")).to have_text(accepted_adr.title)
  end
end
