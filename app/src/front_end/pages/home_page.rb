class HomePage < AppPage
  attr_reader :info_message, :error_message
  def initialize(flash:)
    @info_message = flash.notice
    @error_message = flash.alert
  end
end
