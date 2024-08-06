class Pages::Home < AppPage
  attr_reader :info, :error
  def initialize(info: nil, error: nil)
    @info = info
    @error = error
  end
end
