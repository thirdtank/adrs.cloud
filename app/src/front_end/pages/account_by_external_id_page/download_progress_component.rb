class AccountByExternalIdPage::DownloadProgressComponent < AppComponent2
  attr_reader :download
  def initialize(download:)
    @download = download
  end

  def view_template
    if download.ready?
      div(class: "pa-3 bn shadow-1 br-3 bg-green-900 green-200 dib") do
        h3(class: "ma-0 f-3 flex items-center gap-2") do
          span(class: "w-2") { inline_svg("database-download-icon") }
          span { t(component: :download_ready) }
        end
        p(class: "p i") do
          t(component: :download_ready_text, created: time_tag(timestamp: download.created_at, format: :full_with_tz), deleted: time_tag(timestamp: download.delete_at, format: :full_with_tz))
        end
        a(href: DownloadsWithExternalIdHandler.routing(external_id: download.external_id).to_s, class:"f-3 green-200 db") do
          t(component: :download)
        end
        form_tag(for: DownloadsHandler, class: "mt-4") do
          render(ButtonComponent.new(
            size: :tiny,
            color: :blue,
            label: t(component: :create_new),
            icon: "database-download-icon",
            confirm: t(component: :create_new_confirmation),
          ))
          p(class: "p i f-1") do
            t(component: :create_new_explanation)
          end
        end
      end
    else
      div(class:"pa-3 bn shadow-1 br-3 bg-yellow-900 yellow-200 dib") do
        h3(class: "ma-0 f-3 flex items-center gap-2") do
          span(class: "w-2 flex items-center rotating") do
            inline_svg("loader-icon")
          end
          span { t(component: :download_being_assembled) }
        end
        p(class: "p i mb-0") do
          t(component: :assembled_message)
        end
      end
    end
  end
end
