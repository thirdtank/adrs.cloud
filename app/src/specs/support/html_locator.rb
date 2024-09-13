class Support::HtmlLocator
  include RSpec::Matchers

  def initialize(nokogiri_node)
    @nokogiri_node = nokogiri_node
  end

  def table_captioned(caption)
    caption = @nokogiri_node.css("table caption").detect { |element|
      element.text == caption
    }
    captions_found = @nokogiri_node.css("table caption").map(&:text).join(", ")
    expect(caption).not_to eq(nil),"Found these captions: #{captions_found}"
    caption.parent
  end

  def element(css_selector)
    element = @nokogiri_node.css(css_selector)
    if (element.kind_of?(Nokogiri::XML::NodeSet))
      expect(element.length).to be < 2
      return element.first
    else
      expect([Nokogiri::XML::Node, Nokogiri::XML::Element]).to include(element.class)
      return element
    end
  end
  def element!(css_selector)
    element = @nokogiri_node.css(css_selector)
    if (element.kind_of?(Nokogiri::XML::NodeSet))
      expect(element.length).to eq(1),"#{css_selector}:\n\n#{@nokogiri_node.to_html}"
      return element.first
    else
      expect([Nokogiri::XML::Node, Nokogiri::XML::Element]).to include(element.class)
      return element
    end
  end
end
