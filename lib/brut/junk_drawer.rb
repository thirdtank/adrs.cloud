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

class CallRenderInjectingInfo
  def initialize(object)
    @render_method = object.method(:render)
    args_by_is_kwarg = @render_method.parameters.group_by { |(type,_)| [:key, :keyreq].include?(type) }

    args_by_is_kwarg[false] ||= []
    args_by_is_kwarg[true] ||= []

    if args_by_is_kwarg[false].any?
      raise ArgumentError.new("#{object.class}'s `render` method must only accept keyword args. This one has these non-keyword args: #{args_by_is_kwarg[false].map(&:first).join(", ")}")
    end
    @keyword_args = args_by_is_kwarg[true].map { |(_,name)| name }
  end

  def call_render(**args)
    params = @keyword_args.map { |arg_name|
      [ arg_name, args[arg_name] ]
    }.to_h
    @render_method.call(**params)
  end
end
