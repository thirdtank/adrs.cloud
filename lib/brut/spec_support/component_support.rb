require_relative "flash_support"
module Brut::SpecSupport::ComponentSupport
  include Brut::SpecSupport::FlashSupport

  def render_and_parse(component)
    if component.kind_of?(Brut::FrontEnd::Page)
      result = component.handle!
      case result
      in String => html
        Nokogiri::HTML5(html)
      else
        result
      end
    else
      Nokogiri::HTML5(component.render)
    end
  end

  def routing_for(klass,**args)
    Brut.container.routing.uri(klass,**args)
  end

  def escape_html(...)
    Brut::FrontEnd::Templates::EscapableFilter.escape_html(...)
  end
end
