module Brut::BackEnd::Actions
  autoload(:Validator,"brut/back_end/actions/validator")
  autoload(:Validators,"brut/back_end/actions/validator")
end

class Brut::BackEnd::Action
  include SemanticLogger::Loggable

private

  def new_result = Brut::BackEnd::Result.new

end
