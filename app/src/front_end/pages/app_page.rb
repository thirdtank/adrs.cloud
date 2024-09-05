class AppPage < Brut::FrontEnd::Page
  include AppViewHelpers

  def t(key,**rest)
    Brut::I18n::TMethod.t(keys_to_try(key),**rest)
  rescue I18n::MissingInterpolationArgument => ex
    if ex.key.to_s == "block"
      raise ArgumentError,"One of the keys #{keys_to_try(key).join(", ")} contained a %{block} interpolation value: '#{ex.string}'. This means you must use t_html *and* yield a block to it"
    else
      raise
    end
  end
  def t_html(key,**rest)
    if block_given?
      if rest[:block]
        raise ArgumentError,"t_html was given a block and a block: param. You can't do both "
      end
      rest[:block] = Brut::FrontEnd::Templates::HTMLSafeString.from_string(yield.to_s.strip)
    end
    keys_to_try = [
      "pages.#{self.class}.#{key}",
      "pages.general.#{key}",
    ]
    Brut::I18n::TMethod.t_html(keys_to_try(key),**rest)
  rescue I18n::MissingInterpolationArgument => ex
    if ex.key.to_s == "block"
      raise ArgumentError,"One of the keys #{keys_to_try(key).join(", ")} contained a %{block} interpolation value: '#{ex.string}'. This means that this message is expecting a block given to `t_html`"
    else
      raise
    end
  end

  def keys_to_try(key)
    [
      "pages.#{self.class}.#{key}",
      "pages.general.#{key}",
    ]
  end
end
module Pages
  module Adrs
  end
end

require_relative "home_page"
require_relative "adrs_page"
require_relative "developer_auth_page"
require_relative "adrs_by_external_id_page"
require_relative "new_draft_adr_page"
require_relative "edit_draft_adr_by_external_id_page"
require_relative "shared_adrs_by_shareable_id_page"
require_relative "end_to_end_tests_page"
