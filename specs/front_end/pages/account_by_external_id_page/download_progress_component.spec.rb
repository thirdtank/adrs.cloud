require "spec_helper"

RSpec.describe AccountByExternalIdPage::DownloadProgressComponent do
  context "dowload is ready" do
    it "renders that it's ready" do
      download = Download.new(download: create(:download, :ready))

      component = described_class.new(download:)

      html = render_and_parse(component)

      expect(html.text).to include(t("components.#{described_class}.download_ready"))
    end
  end
  context "download is not ready" do
    it "renders that it's still working" do
      download = Download.new(download: create(:download))

      component = described_class.new(download:)

      html = render_and_parse(component)

      expect(html.text).to include(t("components.#{described_class}.download_being_assembled"))
    end
  end
end
