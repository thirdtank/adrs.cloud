class SubclassMustImplement < StandardError
  def initialize(additional_message=nil)
    message = if additional_message
                "Subclass must implement: #{additional_message}"
              else
                "Subclass must implement"
              end
    super(message)
  end
end
