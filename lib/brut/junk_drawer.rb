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
    args_by_is_kwarg[true]  ||= []

    if args_by_is_kwarg[false].any?
      non_kwargs = args_by_is_kwarg[false].map(&:first).join(", ")
      raise ArgumentError.new(
        "#{object.class}'s `render` method must only accept keyword args. This one has these non-keyword args: #{non_kwargs}"
      )
    end
    @keyword_args = args_by_is_kwarg[true].map { |(_,name)| name }
  end

  def call_render(**args)
    params = @keyword_args.map { |arg_name|
      value = if args.key?(arg_name)
                args[arg_name]
              else
                raise "#{@render_method.owner.name}##{@render_method.name} needs #{arg_name}, however the call to render from #{caller(4,1).join(",")} did not provide it"
              end
      [ arg_name, args[arg_name] ]
    }.to_h
    @render_method.call(**params)
  end
end
