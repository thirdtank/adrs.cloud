class Brut::Infrastructure::Instrumentation
  include SemanticLogger::Loggable
  def initialize
  end

  def instrument(event:,&block)
    block ||= ->() {}

    start     = Time.now
    result    = nil
    exception = nil

    begin
      result = block.()
    rescue => ex
      exception = ex
    end
    stop = Time.now
    notify(event:,start:,stop:,exception:)
    if exception
      raise exception
    else
      result
    end
  end

  def notify(event:,start:,stop:,exception:)
    logger.info("#{event}: #{start}/#{stop} = #{stop-start}: #{exception&.message}")
  end
end
