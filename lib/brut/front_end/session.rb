# A class that represents the current session, as opposed to just a Hash.
# Generally, this can act like a Hash for setting and accessing values stored in the session.
# It provides a few useful additions:
#
# * Your app can extend this to provide an app-specific API around the session.
# * There is direct access to commonly-used data stored in the session, such as the flash.
class Brut::FrontEnd::Session
  def initialize(rack_session:)
    @rack_session = rack_session
  end

  # If the browser has communicate the user's locale, this returns that value.
  def locale_from_browser = self[:_locale_from_browser]

  # Set the locale as reported by the browser.  Setting this in the session prevents repeated
  # attempts to submit it from the browser.
  def locale_from_browser=(locale)
    self[:_locale_from_browser] = locale
  end

  # Get the timezone as reported by the browser, as a TZInfo::Timezone.
  # If none is available or the browser reported an invalid value, this returns nil.
  def timezone_from_browser
    tz_name = self[:_timezone_from_browser]
    if tz_name.nil?
      return nil
    end
    begin
      TZInfo::Timezone.get(tz_name)
    rescue TZInfo::InvalidTimezoneIdentifier => ex
      SemanticLogger[self.class.name].warn(ex)
      nil
    end
  end

  # Set the timezone as reported by the browser. This alleviates the need to keep
  # asking the browser for this information.
  def timezone_from_browser=(timezone)
    if timezone.kind_of?(TZInfo::Timezone)
      timezone = timezone.name
    end
    self[:_timezone_from_browser] = timezone
  end

  def[](key) = @rack_session[key.to_s]

  def[]=(key,value)
    @rack_session[key.to_s] = value
  end

  def delete(key) = @rack_session.delete(key.to_s)

  # Access the flash, as an instance of whatever class has been configured.
  def flash
    Brut.container.flash_class.from_h(self[:_flash])
  end
  def flash=(new_flash)
    self[:_flash] = new_flash.to_h
  end
end
