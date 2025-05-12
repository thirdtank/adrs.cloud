require "spec_helper"

RSpec.describe "Download all data", e2e_timeout: 30_000 do
  include Support::E2E::Login
  it "can add, edit, and archive projects" do
    account = create(:account)
    create(:adr, account: account)
    create(:adr, :accepted, account: account)

    login(page:,account:)
    expect(page).to be_page_for(AdrsPage)

    account_link = page.locator("a", hasText: t("pages.AdrsPage.your_account"))
    account_link.click

    expect(page).to be_page_for(AccountByExternalIdPage)

    download_tab = page.locator("a", hasText: t("pages.AccountByExternalIdPage.tabs.download.title"))
    download_tab.click

    download_button = page.locator("#download-panel button", hasText: t("pages.AccountByExternalIdPage.downloads.create_download"))
    download_button.click

    expect(page).to be_page_for(AccountByExternalIdPage)
    selected_tab = page.locator("brut-tabs [aria-selected=true]")
    expect(selected_tab).to have_text("Download")
    download_link = page.locator("#download-panel a", hasText: t("components.AccountByExternalIdPage::DownloadProgressComponent.download"))
    download = page.expect_download do
      download_link.click
    end

    contents = File.read(download.path)
    expect(download.suggested_filename).to match(/^\d\d\d\d-\d\d-\d\dT\d\d-\d\d-\d\d-adrs-download.html$/)
    parsed_contents = begin
                        Nokogiri::HTML5(contents)
                      rescue => ex
                        fail "Could not parse '#{contents}' as HTML: #{ex.message}"
                      end
    expect(parsed_contents.css("section[title='adrs'] section").length).to eq(2)
    expect(parsed_contents.css("section[title='projects'] section").length).to eq(1)
  end

end
