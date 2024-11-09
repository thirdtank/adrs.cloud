class DownloadsCLI < Brut::CLI::App
  description "Manage ADR downloads"
  requires_project_env

  class Status < Brut::CLI::Command
    description "Show the number of expired downloads from the database"
    opts.on("--use-exit","Instead of printing the status, exit 0 if there are no expired downloads, 1 otherwise")

    def execute
      count = Download.num_expired
      if options.use_exit?
        return count == 0 ? 0 : 1
      end
      out.puts t("clis.downloads.num_expired", count:)
    end
  end

  class Delete < Brut::CLI::Command
    description "Delete any expired downloads"
    opts.on("--use-exit","Instead of printing the number deleted, exit 0 if nothing was deleted, 1 otherwise")

    def execute
      num_deleted = Download.delete_expired
      if options.use_exit?
        return num_deleted == 0 ? 0 : 1
      end
      out.puts t("clis.downloads.num_deleted", count: num_deleted)
    end
  end
end
