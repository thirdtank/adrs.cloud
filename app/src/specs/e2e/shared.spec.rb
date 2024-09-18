require "spec_helper"

RSpec.describe "ADRs can be shared or not" do
  it "can be shared" do
    account = create(:account)
    adr = create(:adr, :accepted, account: account)

    page = browser.new_page
    page.default_timeout = 5_000

    page.goto("http://0.0.0.0:6502/")
    button = page.locator("form[action='/auth/developer'] button")
    button.click

    field = page.locator("input[name=email]")
    field.fill(account.email)
    button = page.locator("form button")
    button.click

    expect(page.locator("h1")).to have_text("ADRs")

    link = page.locator("a[href='#{AdrsByExternalIdPage.routing(external_id: adr.external_id)}']")
    link.click

    share_button = page.locator("button[formaction='#{SharedAdrsWithExternalIdHandler.routing(external_id: adr.external_id)}']")
    share_button.click

    nevermind_button = page.locator("brut-confirmation-dialog button[value='cancel']")
    nevermind_button.click

    share_button.click

    confirm_button = page.locator("brut-confirmation-dialog button[value='ok']")
    confirm_button.click

    shareable_link = page.locator("a", hasText: "View Shareable Page")
    shareable_href = shareable_link[:href]

    logout_link = page.locator("a", hasText: "Logout")
    logout_link.click

    button = page.locator("form[action='/auth/developer'] button") # ensure page loads and we are logged out

    page.goto("http://0.0.0.0:6502" + shareable_href)
    expect(page.locator("h2")).to have_text(adr.title)
    expect(page.locator("section[aria-label='context']")).to   have_text(adr.context)
    expect(page.locator("section[aria-label='facing']")).to    have_text(adr.facing)
    expect(page.locator("section[aria-label='decision']")).to  have_text(adr.decision)
    expect(page.locator("section[aria-label='neglected']")).to have_text(adr.neglected)
    expect(page.locator("section[aria-label='achieve']")).to   have_text(adr.achieve)
    expect(page.locator("section[aria-label='accepting']")).to have_text(adr.accepting)
    expect(page.locator("section[aria-label='because']")).to   have_text(adr.because)
    expect(page.locator("h3", hasText: 'Accepted')).to         have_text(adr.accepted_at.to_s)
    expect(page.locator("button").count).to eq(0)

    page.goto("http://0.0.0.0:6502/")
    button = page.locator("form[action='/auth/developer'] button")
    button.click

    field = page.locator("input[name=email]")
    field.fill(account.email)
    button = page.locator("form button")
    button.click

    expect(page.locator("h1")).to have_text("ADRs")

    link = page.locator("a[href='#{AdrsByExternalIdPage.routing(external_id: adr.external_id)}']")
    link.click

    make_private_button = page.locator("button[formaction='#{PrivateAdrsWithExternalIdHandler.routing(external_id: adr.external_id)}']")
    make_private_button.click

    confirm_button = page.locator("brut-confirmation-dialog button[value='ok']")
    confirm_button.click

    expect(page.locator("a", hasText: "View Shareable Page")).to have_count(0)
  end

end
