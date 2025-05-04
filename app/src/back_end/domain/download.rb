require "phlex"
class Download

  extend Forwardable

  def self.for_account(account:)
    existing_download = account.download
    if existing_download
      Download.new(download: existing_download)
    else
      nil
    end
  end

  def self.create(authenticated_account:)
    existing_download = authenticated_account.account.download
    download = if existing_download.nil?
                 DB::Download.new(account: authenticated_account.account)
               elsif existing_download.data_ready_at.nil?
                 existing_download
               else
                 existing_download.delete
                 DB::Download.new(account: authenticated_account.account)
               end

    Download.new(download:)
  end

  def self.find!(external_id:,account:)
    download = DB::Download.find!(external_id:, account:)
    self.new(download:)
  end

  def self.num_expired
    DB::Download.where(Sequel.lit("delete_at < now()")).count
  end

  def self.delete_expired
    DB::Download.where(Sequel.lit("delete_at < now()")).delete
  end

  def initialize(download:)
    @download = download
  end

  def save
    @download.save
    AssembleDownloadJob.perform_in(1,external_id)
  end

  class PhlexComponent < Phlex::HTML
    def initialize(download:)
      @download = download
    end

    def view_template
      html do
        body do
          main do
            section(title: "adrs") do
              @download.account.adrs.each do |adr|
                section(id: adr.external_id) do
                  h2 { adr.title }
                  dl do
                    adr.as_json.each do |key, value|
                      if key != :external_id && key != :title
                        dt { key.to_s }
                        dd { value.to_s }
                      end
                    end
                  end
                end
              end
            end
            section(title: "projects") do
              @download.account.projects.each do |project|
                section(id: project.external_id) do
                  h2 { project.name }
                  dl do
                    project.as_json.each do |key,value|
                      if key != :external_id && key != :name
                        dt { key.to_s }
                        dd { value.to_s }
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def assemble
    html = PhlexComponent.new(download: @download).call
    @download.update(
      data_ready_at: Time.now,
      delete_at: Time.now + (60 * 60 * 24),
      all_data: html.to_s,
    )
  end

  def ready? = !@download.data_ready_at.nil?

  def_delegators :@download, :all_data, :external_id, :created_at, :delete_at, :data_ready_at

end
