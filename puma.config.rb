require "semantic_logger"

on_worker_boot do
  # Re-open appenders after forking the process
  SemanticLogger.reopen
end
