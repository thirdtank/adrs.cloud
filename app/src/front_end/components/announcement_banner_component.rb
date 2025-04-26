class AnnouncementBannerComponent < AppComponent
  def initialize(flash:, site_announcement: :default_site_announcement, clock:)
    @shown_role = if flash.alert?
                    "alert"
                  elsif flash.notice?
                    "status"
                  else
                    "note"
                  end
    @clock = clock
    @flash = flash
    @site_announcement = site_announcement
  end
  def view_template
    time = ::I18n.l(@clock.now,format: :full_with_tz)
    default_classes = [
      "pv-2",
      "ph-3",
      "f-1",
      "flex",
      "items-center",
      "gap-3",
    ]

    adr_announcement_banner(
      class: "db w-100", 
      default_show_role: @shown_role,
      show_warnings: true
    ) do
      {
        "alert" => [
          [ "bg-red-800", "red-300" ],
          "exclamation-triangle-icon",
          @flash.alert,
        ],
        "status" => [
          [ "bg-blue-800", "blue-300" ],
          "info-circle-icon",
          @flash.notice,
        ],
        "note" => [
          [ "bg-gray-800", "gray-300" ],
          "megaphone-icon",
          @site_announcement,
        ],
      }.each do |role, (css_classes, icon, i18_key)|
        hidden = @shown_role != role
        div(
          hidden:,
          role:,
          class: css_classes + default_classes,
        ) do
          span(class: "w-2 flex flex-column justify-center") do
            inline_svg(icon)
          end
          p(class: "p ma-0") do
            if i18_key
              t(i18_key, time: time)
            end
          end
        end
      end
    end
  end

end
