require_relative "flash_support"
module Brut::SpecSupport::ComponentSupport
  include Brut::SpecSupport::FlashSupport

  def render_and_parse(component, entire_document:false)
    if component.kind_of?(Brut::FrontEnd::Page)
      if entire_document
        raise ArgumentError,"You should not use entire_document: true when callingn render_and_parse with a page"
      end
      result = component.handle!
      case result
      in String => html
        Nokogiri::HTML5(html)
      else
        result
      end
    else
      document = Nokogiri::HTML5(component.render)
      component_html = document.css("body")
      if component_html
        non_blank_text_elements = component_html.children.select { |element|
          if element.kind_of?(Nokogiri::XML::Text) && element.text.to_s.strip == ""
            false
          else
            true
          end
        }
        if non_blank_text_elements.size == 1
          non_blank_text_elements[0]
        elsif entire_document
          document
        else
          raise "#{component.class} rendered #{non_blank_text_elements.size} elements other than blank text:\n\n#{non_blank_text_elements.map(&:name)}. Set entire_document: true to render_and_parse to return the entire document wrapped in <html><body>"
        end
      else
        raise "#{component.class} did not render HTML properly"
      end
    end
  end

  def routing_for(klass,**args)
    Brut.container.routing.uri(klass,**args)
  end

  def escape_html(...)
    Brut::FrontEnd::Templates::EscapableFilter.escape_html(...)
  end
end
