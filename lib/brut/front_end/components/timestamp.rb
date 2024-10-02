require "rexml"
class Brut::FrontEnd::Components::Timestamp < Brut::FrontEnd::Component
  include Brut::I18n
  def initialize(timestamp:, format: :full, skip_year_if_same: true, attribute_format: :iso_8601, **only_contains_class)
    @timestamp = timestamp
    format_keys = [
      "general.timestamp.#{format}"
    ]
    if @timestamp.year == Time.now.year && skip_year_if_same
      format_keys.unshift(format_keys[0] + "_no_year")
    end
    @format = t_direct(format_keys)
    @attribute_format = t_direct("general.timestamp.#{attribute_format}")
    @class_attribute = only_contains_class[:class] || ""
  end


  def render
    html_tag(:time, class: @class_attribute, datetime: @timestamp.strftime(@attribute_format)) do
      @timestamp.strftime(@format)
    end
  end
end
