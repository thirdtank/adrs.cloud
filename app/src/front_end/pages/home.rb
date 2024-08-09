class Pages::Home < AppPage
  attr_reader :info, :check_result
  def initialize(info: nil, check_result: nil)
    @info = info
    @check_result = check_result
  end
end
