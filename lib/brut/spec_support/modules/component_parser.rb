module Brut::SpecSupport::ComponentParser

  def render_and_parse(component)
    Nokogiri::HTML5(component.render)
  end

end
