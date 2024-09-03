module Brut::SpecSupport::ComponentSupport

  def render_and_parse(component)
    Nokogiri::HTML5(component.render)
  end

  def empty_flash = Brut::FrontEnd::Flash.new

  def flash_from(hash)
    Brut::FrontEnd::Flash.from_h(messages: hash)
  end

end
