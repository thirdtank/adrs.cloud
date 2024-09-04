require_relative "flash_support"
module Brut::SpecSupport::ComponentSupport
  include Brut::SpecSupport::FlashSupport

  def render_and_parse(component)
    Nokogiri::HTML5(component.render)
  end

  def routing_for(klass,**args)
    Brut.container.routing.for(klass,**args)
  end
end
