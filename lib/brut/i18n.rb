# Interface for translations.  This is prefered over using Ruby's I18n directly.
# This is intended to be mixed-in to any class that requires this, so that you can more
# expediently access the `t` method.
module Brut::I18n

  # Needs:
  #
  # - translate a key
  # - translate an error message, using "this field" when needed
  # - translate an error message, using Brut's defaults or specific ones if present
  #
  # Said another way
  #
  # - manage arbitrary strings
  # - manage validation errors that can be specific to an object

  # Core method of this module.  You likely want one of the convienience methods. This will look up
  # translations based on the keys given, returning the first one that is defined. If none are found
  # it will raise `I18n::MissingTranslation`.  If the key's value requires an interpolation argument,
  # `I18N::MissingInterpolationArgument` is raised.  This is also raised if the key has pluralizations
  # and `count` is omitted.
  #
  # This will also provide the interpolation argument `field` with the value of whatever `cv.this_field` is
  # translated to.  If you specify a value for `field` in `interpolated_values`, that value will be used instead.
  # This means that field-based constraint violation error messages will say something like
  # "This field is required" if you don't specify the field name.
  #
  # @param [Array<String>,Array<Symbol>] keys list of keys representing what is to be translated. The
  #                                           first key found will be used. If no key in the list is found
  #                                           will raise a I18n::MissingTranslation
  # @param [Hash] interpolated_values value to use for interpolation of the key's translation
  # @option interpolated_values [Numeric] count Special interpolation to control pluralization.
  #
  # @raise [I18n::MissingTranslation] if no translation is found
  # @raise [I18n::MissingInterpolationArgument] if interpolation arguments are missing, or if the key
  #                                             has pluralizations and no count: was given
  def t(keys,interpolated_values={})
    keys = Array(keys)
    default_interpolated_values = {
      field: this_field_value,
    }
    result = ::I18n.t(keys.first, default: keys[1..-1],raise: true, **default_interpolated_values.merge(interpolated_values))
    if result.kind_of?(Hash)
      raise I18n::MissingInterpolationArgument.new(:count,interpolated_values,keys.join(","))
    end
    Brut::FrontEnd::Template.escape_html(result)
  end

  # Translates the given key, but does not do any HTML escaping.  Any String values
  # in interpolated_values *will* be escaped, however.  To avoid that, those strings
  # can be wrapped in a Brut::FrontEnd::Templates::HTMLSafeString.
  def t_html(keys,interpolated_values={})
    keys = Array(keys)
    default_interpolated_values = {
      field: this_field_value,
    }
    escaped_interpolated_values = interpolated_values.map { |key,value|
      if value.kind_of?(String)
        [ key, Brut::FrontEnd::Template.escape_html(value) ]
      else
        [ key, value ]
      end
    }.to_h
    result = ::I18n.t(keys.first, default: keys[1..-1],raise: true, **default_interpolated_values.merge(escaped_interpolated_values))
    if result.kind_of?(Hash)
      raise I18n::MissingInterpolationArgument.new(:count,interpolated_values,keys.join(","))
    end
    result
  end

  def this_field_value
    @__this_field_value ||= ::I18n.t("cv.this_field", raise: true)
  end
end
