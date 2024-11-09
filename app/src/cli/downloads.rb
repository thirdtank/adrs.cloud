class DownloadsCLI < Brut::CLI::App
  description "Manage ADR downloads"
  requires_project_env

  class Status < Brut::CLI::Command
    description "Trim any expired downloads from the database"

    def execute
      out.puts t("clis.downloads.num_expired", count: Download.num_expired)
    end
  end
end
