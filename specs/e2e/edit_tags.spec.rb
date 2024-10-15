require "spec_helper"

RSpec.describe "Edit tags for an ADR" do
  include Support::E2E::Login
  it "can add and remove tags" do
    account = create(:account)
    adr = create(:adr, :accepted, account: account, project: account.projects.first, tags: [ "foo" ])
    login(page:,account:)

    view_link = page.locator("a[href='#{AdrsByExternalIdPage.routing(external_id: adr.external_id)}']")
    view_link.click

    expect(page.locator("section[aria-label='context']")).to   have_text(adr.context)
    expect(page.locator("section[aria-label='facing']")).to    have_text(adr.facing)
    expect(page.locator("section[aria-label='decision']")).to  have_text(adr.decision)
    expect(page.locator("section[aria-label='neglected']")).to have_text(adr.neglected)
    expect(page.locator("section[aria-label='achieve']")).to   have_text(adr.achieve)
    expect(page.locator("section[aria-label='accepting']")).to have_text(adr.accepting)
    expect(page.locator("section[aria-label='because']")).to   have_text(adr.because)

    edit_button = page.locator("button", hasText: "Edit")

    edit_button.click
    tags_textarea = page.locator("textarea[name='tags']")
    tags_textarea.fill("blah, crud, bleorgh")

    save_button = page.locator("button", hasText: "Save Tags")
    save_button.click

    tag_editor_view = page.locator("adr-tag-editor-view")
    expect(tag_editor_view).to have_text("blah")
    expect(tag_editor_view).to have_text("crud")
    expect(tag_editor_view).to have_text("bleorgh")
    expect(tag_editor_view.text_content).not_to include("foo")
  end

end
