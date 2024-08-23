# Thrown when a codepath should never have been allowed
# to occur.  This is useful is signaling that the system
# has some sort of bug in its integration. For example,
# attempting to perform an action that the UI should've
# prevent.ed
class Brut::BackEnd::Errors::Bug < Brut::BackEnd::Error
end
