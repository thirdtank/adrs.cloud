class Brut::FrontEnd::Session
  def initialize(rack_session:)
    @rack_session = rack_session
  end

  def[](key) = @rack_session[key.to_s]

  def[]=(key,value)
    @rack_session[key.to_s] = value
  end

  def delete(key) = @rack_session.delete(key.to_s)

  def flash
    Brut.container.flash_class.from_h(self[:_flash])
  end
  def flash=(new_flash)
    self[:_flash] = new_flash.to_h
  end
end
