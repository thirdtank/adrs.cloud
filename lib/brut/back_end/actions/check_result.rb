class Brut::BackEnd::Actions::CheckResult
  attr_reader :constraint_violations, :context
  def initialize
    @constraint_violations = {}
    @context = {}
  end

  def constraint_violation!(object:nil,
                            field: nil,
                            key:,
                            context: {})
    object ||= General
    field  ||= General
    @constraint_violations[object] ||= {}
    @constraint_violations[object][field] ||= {}
    @constraint_violations[object][field][key] = context
  end

  def each_violation(&block)
    @constraint_violations.each do |object,fields|
      fields.each do |field,keys|
        keys.each do |key,context|
          block.(object,field,key,context)
        end
      end
    end
  end

  def save_context(hash)
    @context = @context.merge(hash)
  end

  def [](key_in_context)
    @context.fetch(key_in_context)
  rescue KeyError => ex
    raise KeyError.new(
      "Context did not contain '#{key_in_context}' (#{key_in_context.class}). Context has these keys: #{@context.keys.join(',')}",
      receiver: ex.receiver,
      key: ex.key)
  end


  def can_call? =  self.constraint_violations.empty?
  def invalid?  = !self.can_call?
  def valid?    =  self.can_call?

  def deconstruct_keys(*)
    @context
  end

private

  General = Object.new
end
