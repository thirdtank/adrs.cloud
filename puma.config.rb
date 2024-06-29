require "semantic_logger"

class FML
  def initialize(logger)
    @logger = logger
  end
  def write(*args)
    @logger.log :info, *args
  end
end
custom_logger FML.new(SemanticLogger["puma"])
