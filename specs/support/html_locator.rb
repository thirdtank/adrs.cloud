class Support::HtmlLocator
  include RSpec::Matchers

  def initialize(nokogiri_node)
    @nokogiri_node = nokogiri_node
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
      expect(element.length).to eq(1),"#{css_selector} matched #{element.length} elements, not exactly 1:\n\n#{@nokogiri_node.to_html}"
      return element.first
    else
      expect([Nokogiri::XML::Node, Nokogiri::XML::Element]).to include(element.class)
      return element
    end
  end
end
