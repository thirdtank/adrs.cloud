require "pathname"
require "fileutils"

# We don't want the setup method to have to do all this error
# checking, and we also want to explicitly log what we are
# executing. Thus, we use this method instead of Kernel#system
def system!(*args)
  log "Executing #{args}"
  if system(*args)
    log "#{args} succeeded"
  else
    log "#{args} failed"
    abort
  end
end

# It's helpful to know what messages came from this
# script, so we'll use log instead of `puts`
def log(message)
  puts "[ #{$0} ] #{message}"
end

ROOT_DIR = ((Pathname(__dir__) / ".." ).expand_path)
