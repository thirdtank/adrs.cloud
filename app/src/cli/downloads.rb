require "brut/cli"
class DownloadsCLI < Brut::CLI::Commands::BaseCommand
  def description = "Manage ADR downloads"
  def name = "downloads"

  class Status < Brut::CLI::Commands::BaseCommand
    include Brut::I18n::ForCLI
    def description = "Show the number of expired downloads from the database"
    def bootstrap? = true
    def default_rack_env = "development"
    def opts = [
      [ "--use-exit","Instead of printing the status, exit 0 if there are no expired downloads, 1 otherwise" ]
    ]

    def run
      count = Download.num_expired
      if options.use_exit?
        return count == 0 ? 0 : 1
      end
      puts t("clis.downloads.num_expired", count:)
    end
  end

  class Delete < Brut::CLI::Commands::BaseCommand
    include Brut::I18n::ForCLI
    def description = "Delete any expired downloads"
    def bootstrap? = true
    def default_rack_env = "development"
    def opts = [
      [ "--use-exit","Instead of printing the number deleted, exit 0 if there are no expired downloads, 1 otherwise" ]
    ]

    def run
      num_deleted = Download.delete_expired
      if options.use_exit?
        return num_deleted == 0 ? 0 : 1
      end
      puts t("clis.downloads.num_deleted", count: num_deleted)
    end
  end
end
