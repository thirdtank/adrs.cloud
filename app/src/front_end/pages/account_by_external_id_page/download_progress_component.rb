class AccountByExternalIdPage::DownloadProgressComponent < AppComponent
  attr_reader :download
  def initialize(download:)
    @download = download
  end

  def view_template
    if download.ready?
      div(class: "pa-3 bn shadow-1 br-3 bg-green-900 green-200 dib") do
        h3(class: "ma-0 f-3 flex items-center gap-2") do
          span(class: "w-2") { inline_svg("database-download-icon") }
          span { t(:download_ready) }
        end
        p(class: "p i") do
          t([:download_ready_text, :created]) do
            render time_tag(timestamp: download.created_at, format: :full_with_tz)
          end
          t([:download_ready_text, :available]) do
            render time_tag(timestamp: download.delete_at, format: :full_with_tz)
          end
        end
        a(href: DownloadsWithExternalIdHandler.routing(external_id: download.external_id), class:"f-3 green-200 db") do
          t(:download)
        end
        FormTag(for: DownloadsHandler, class: "mt-4") do
          render(ButtonComponent.new(
            size: :tiny,
            color: :blue,
            label: t(:create_new),
            icon: "database-download-icon",
            confirm: t(:create_new_confirmation),
          ))
          p(class: "p i f-1") do
            t(:create_new_explanation)
          end
        end
      end
    else
      div(class:"pa-3 bn shadow-1 br-3 bg-yellow-900 yellow-200 dib") do
        h3(class: "ma-0 f-3 flex items-center gap-2") do
          span(class: "w-2 flex items-center rotating") do
            inline_svg("loader-icon")
          end
          span { t(:download_being_assembled) }
        end
        p(class: "p i mb-0") do
          t(:assembled_message)
        end
      end
    end
  end
end
