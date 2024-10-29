require "brut"

require "pathname"

Brut.container.store_required_path(
  "project_root",
  "Root of the entire project's source code checkout",
  (Pathname(__dir__) / "..").expand_path)


$: << File.join(Brut.container.project_root,"app","src")

require "app"

#App.new.boot!
#App.new.configure_only!

