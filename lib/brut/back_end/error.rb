module Brut::BackEnd::Errors
  autoload(:Bug,"brut/back_end/errors/bug")
  autoload(:NotFound,"brut/back_end/errors/not_found")
end

# Base error useful for BackEnd operations.  You are intended to use these
# instead of simple `raise "some problem"` for raising exceptions.
class Brut::BackEnd::Error < StandardError
end
