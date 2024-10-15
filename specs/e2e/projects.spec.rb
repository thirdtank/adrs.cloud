require "spec_helper"

RSpec.describe "Manage Projects" do
  include Support::E2E::Login
  include Brut::I18n
  it "can add, edit, and archive projects" do
    account = create(:account)

    login(page:,account:)
    expect(page).to be_page_for(AdrsPage)

    account_link = page.locator("a", hasText: t("pages.AdrsPage.your_account"))
    account_link.click

    expect(page).to be_page_for(AccountByExternalIdPage)

    projects_tab = page.locator("a", hasText: t("pages.AccountByExternalIdPage.tabs.projects.title"))
    projects_tab.click

    add_new_link = page.locator("a", hasText: t("pages.AccountByExternalIdPage.projects.add_new"))
    add_new_link.click

    expect(page).to be_page_for(NewProjectPage)

    submit_button = page.locator("form button[title='#{t("components.Projects::FormComponent.actions.new")}']")
    submit_button.click

    name_field = page.locator("label", has: page.locator("input[name='name']"))
    expect(name_field).to have_text("This field is required")

    name_field.fill(account.projects.first.name)

    submit_button.click
    expect(name_field).to have_text(t("general.cv.be.taken", field: t("general.cv.this_field")).capitalize.to_s)

    name_field.fill("Some New Project")
    submit_button.click

    expect(page).to be_page_for(AccountByExternalIdPage)
    selected_tab = page.locator("brut-tabs [aria-selected=true]")
    expect(selected_tab).to have_text("Projects")
    expect(page.locator("#projects-panel")).to have_text("Some New Project")

    row = page.locator("#projects-panel tr[title='Some New Project']")
    edit_link = row.locator("a", hasText: "Edit")
    edit_link.click

    expect(page).to be_page_for(EditProjectByExternalIdPage)

    name_field = page.locator("label", has: page.locator("input[name='name']"))
    name_field.fill(account.projects.first.name)

    submit_button = page.locator("form button[title='#{t("components.Projects::FormComponent.actions.edit")}']")

    submit_button.click
    expect(name_field).to have_text(t("general.cv.be.taken", field: t("general.cv.this_field")).capitalize.to_s)

    name_field.fill("Some Changed Project")
    description_field = page.locator("textarea[name='description']")
    description_field.fill("This is some description")
    sharing_checkbox = page.locator("input[type='checkbox'][name='adrs_shared_by_default']")
    sharing_checkbox.check

    submit_button.click

    expect(page).to be_page_for(AccountByExternalIdPage)
    selected_tab = page.locator("brut-tabs [aria-selected=true]")
    expect(selected_tab).to have_text("Projects")
    expect(page.locator("#projects-panel")).to have_text("Some Changed Project")

    row = page.locator("#projects-panel tr[title='Some Changed Project']")
    expect(row).to have_text("This is some description")
    expect(row).to have_text(t("pages.AccountByExternalIdPage.projects.default_shared").to_s)

    archive_button = row.locator("form button")
    archive_button.click

    nevermind_button = page.locator("brut-confirmation-dialog button[value='cancel']")
    nevermind_button.click

    archive_button.click

    confirm_button = page.locator("brut-confirmation-dialog button[value='ok']")
    confirm_button.click

    expect(page).to be_page_for(AccountByExternalIdPage)
    selected_tab = page.locator("brut-tabs [aria-selected=true]")
    expect(selected_tab).to have_text("Projects")
    expect(page.locator("#projects-panel")).to have_text("Some Changed Project")

    row = page.locator("#projects-panel tr[title='Some Changed Project']")
    expect(row).to have_text("Archived")
  end

end
