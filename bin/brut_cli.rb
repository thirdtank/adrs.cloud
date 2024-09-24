require "bundler"
Bundler.setup(:default, ENV["RACK_ENV"].to_sym)

# Not needed once Brut is modularized
BRUT_PATH = File.join(File.dirname($0),"..","lib")
$: << BRUT_PATH
require "brut"

Brut.container.store_required_path(
  "project_root",
  "Root of the entire project's source code checkout",
  (Pathname(__dir__) / "..").expand_path)

APP_SRC_PATH = File.join(Brut.container.project_root,"app","src")
$: << APP_SRC_PATH

require "app"
require "pathname"

require_relative "bin_kit"

log "Creating App"
app = App.new
log "Configuring App and Brut"
app.configure_only!
