class Brut::Forms::NonConformingValue
  attr_reader :value, :exception
  def initialize(value,exception)
    @value = value
    @exception = exception
  end
  def conforming? = false
  def error = exception.message
end

