class Support::HtmlLocator

  include RSpec::Matchers

  def initialize(rendered_html)
    @rendered_html = rendered_html
  end

  def table_captioned(caption)
    caption = @rendered_html.css("table caption").detect { |element|
      element.text == caption
    }
    expect(caption).not_to eq(nil)
    caption.parent
  end

  def element!(css_selector)
    element = @rendered_html.css(css_selector)
    if (element.kind_of?(Nokogiri::XML::NodeSet))
      expect(element.length).to eq(1)
      return element.first
    else
      expect([Nokogiri::XML::Node, Nokogiri::XML::Element]).to include(element.class)
      return element
    end
  end
end
