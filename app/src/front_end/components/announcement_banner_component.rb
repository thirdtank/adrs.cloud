class AnnouncementBannerComponent < AppComponent
  attr_reader :flash, :site_announcement
  def initialize(flash:, site_announcement: :use_default)
    @flash = flash
    @site_announcement = if site_announcement == :use_default
                           t_html(:default_site_announcement)
                         else
                           t_html(site_announcement)
                         end
  end

  def colors
    if @flash.alert?
      "bg-red-800 red-300"
    elsif @flash.notice?
      "bg-blue-800 blue-300"
    else
      "bg-gray-800 gray-300"
    end
  end

  def icon
    if @flash.alert?
      "exclamation-triangle-icon"
    elsif @flash.notice?
      "info-circle-icon"
    else
      "megaphone-icon"
    end
  end

  def role
    if @flash.alert?
      "alert"
    else
      "status"
    end
  end

  def text
    if @flash.alert?
      t_html(@flash.alert)
    elsif @flash.notice?
      t_html(@flash.notice)
    else
      @site_announcement
    end
  end
end
