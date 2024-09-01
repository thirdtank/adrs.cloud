class HomePage < AppPage
  attr_reader :info_message
  def initialize(flash:)
    @info_message = flash[:notice]
  end
end
