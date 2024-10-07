class AnnouncementBannerComponent < AppComponent
  attr_reader :messages

  Message = Data.define(:role, :css_classes, :svg, :i18_key, :show)

  def initialize(flash:, site_announcement: :default_site_announcement)

    @messages = []

    @messages << Message.new(role: "alert",
                             css_classes: "bg-red-800 red-300",
                             svg: "exclamation-triangle-icon",
                             i18_key: flash.alert,
                             show: flash.alert?)
    @messages << Message.new(role: "status",
                             css_classes: "bg-blue-800 blue-300",
                             svg: "info-circle-icon",
                             i18_key: flash.notice,
                             show: !flash.alert? && flash.notice?)
    @messages << Message.new(role: "note",
                             css_classes: "bg-gray-800 gray-300",
                             svg: "megaphone-icon",
                             i18_key: site_announcement,
                             show: !flash.alert? && !flash.notice?)
  end

end
