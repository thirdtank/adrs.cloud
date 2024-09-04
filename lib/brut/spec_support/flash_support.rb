module Brut::SpecSupport::FlashSupport
  def empty_flash = Brut::FrontEnd::Flash.new

  def flash_from(hash)
    Brut::FrontEnd::Flash.from_h(messages: hash)
  end
end
