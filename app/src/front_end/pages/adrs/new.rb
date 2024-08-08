class Pages::Adrs::New < AppPage
  attr_reader :form
  def initialize(args={})
    super(args)
    @form = args[:form]
  end
end
