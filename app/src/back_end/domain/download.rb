require "rexml"
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

  def initialize(download:)
    @download = download
  end

  def save
    @download.save
    AssembleDownloadJob.perform_in(1,external_id)
  end

  def assemble
    html = REXML::Document.new("<!DOCTYPE html>")
    main = html.add_element("html").add_element("body").add_element("main")

    adrs = main.add_element("section")
    adrs.add_attribute("title","adrs")
    projects = main.add_element("section")
    projects.add_attribute("title","projects")

    @download.account.adrs.each do |adr|
      section = adrs.add_element("section")
      section.add_attribute("id",adr.external_id)
      h2 = section.add_element("h2")
      h2.text = adr.title
      dl = section.add_element("dl")
      adr.as_json.each do |key,value|
        if key != :external_id && key != :title
          dt = dl.add_element("dt")
          dt.text=key.to_s
          dd = dl.add_element("dd")
          dd.text=value.to_s
        end
      end
    end
    @download.account.projects.each do |project|
      section = projects.add_element("section")
      section.add_attribute("id",project.external_id)
      h2 = section.add_element("h2")
      h2.text = project.name
      dl = section.add_element("dl")
      project.as_json.each do |key,value|
        if key != :external_id && key != :name
          dt = dl.add_element("dt")
          dt.text=key.to_s
          dd = dl.add_element("dd")
          dd.text=value
        end
      end
    end
    @download.update(
      data_ready_at: Time.now,
      delete_at: Time.now + (60 * 60 * 24),
      all_data: html.to_s,
    )
  end

  def ready? = !@download.data_ready_at.nil?

  def_delegators :@download, :all_data, :external_id, :created_at, :delete_at, :data_ready_at

end
