require "spec_helper"
RSpec.describe Download do
  describe "::for_account(account:)" do
    context "there is an existing download" do
      it "returns a Download for the account's download record" do
        db_download = create(:download)
        download = Download.for_account(account: db_download.account)
        expect(download).not_to eq(nil)
        expect(download.external_id).to eq(db_download.external_id)
      end
    end
    context "there is not an existing download" do
      it "returns nil" do
        account = create(:account)
        expect(Download.for_account(account:)).to eq(nil)
      end
    end
  end
  describe "::create(authenticated_account:)" do
    context "there is an existing download" do
      context "it is ready" do
        it "deletes the existing one and returns a new, unsaved one" do
          db_download = create(:download, :ready)
          account = db_download.account
          download = Download.create(authenticated_account: AuthenticatedAccount.new(account:))
          expect(download).not_to eq(nil)
          account.reload
          expect(DB::Download.find(id: db_download.id)).to eq(nil)
          expect(account.download).to eq(nil)
          expect(download.created_at).to eq(nil)
          expect(download.external_id).to eq(nil)
        end
      end
      context "it is not ready" do
        it "returns it" do
          db_download = create(:download)
          account = db_download.account
          download = Download.create(authenticated_account: AuthenticatedAccount.new(account:))
          expect(download).not_to eq(nil)
          account.reload
          expect(DB::Download.find(id: db_download.id)).to eq(db_download)
          expect(account.download).to eq(db_download)
          expect(download.external_id).to eq(db_download.external_id)
        end
      end
    end
    context "there is not an existing download" do
      it "creates, but does not save, a new one" do
        account = create(:account)
        download = Download.create(authenticated_account: AuthenticatedAccount.new(account:))
        expect(download).not_to eq(nil)
        expect(account.download).not_to eq(nil)
        expect(download.created_at).to eq(nil)
        expect(download.external_id).to eq(nil)
      end
    end
  end
  describe "::find!(external_id:,account:)" do
    context "download exists" do
      context "and it belongs to the account" do
        it "returns a Download wrapping it" do
          db_download = create(:download)
          account = db_download.account
          download = Download.find!(account:,external_id:db_download.external_id)
          expect(download).not_to eq(nil)
          expect(download.external_id).to eq(db_download.external_id)
        end
      end
      context "and it does not belong to the account" do
        it "blows up" do
          db_download = create(:download)
          account = create(:account)
          expect {
            Download.find!(account:,external_id:db_download.external_id)
          }.to raise_error(Brut::Framework::Errors::NotFound)
        end
      end
    end
    context "download does not exist" do
      it "blows up" do
        account = create(:account)
        expect {
          Download.find!(account:,external_id:"nonexistent")
        }.to raise_error(Brut::Framework::Errors::NotFound)
      end
    end
  end
  describe "#save" do
    it "saves the download and queues a job to assemble it" do
      authenticated_account = create(:authenticated_account)
      download = Download.create(authenticated_account:)

      download.save
      db_download = authenticated_account.account.download

      expect(download.external_id).to eq(db_download.external_id)
      expect(AssembleDownloadJob.jobs.size).to eq(1)
    end
  end
  describe "#assemble" do
    it "fills in the job with the necessary data" do
      db_download = create(:download)
      projects = [
        db_download.account.projects.first,
        create(:project, account: db_download.account),
        create(:project, account: db_download.account),
      ]
      adrs = [
        create(:adr, account: db_download.account, project: projects[0]),
        create(:adr, :rejected, account: db_download.account, project: projects[1]),
        create(:adr, :accepted, account: db_download.account, project: projects[2]),
        create(:adr, :accepted, account: db_download.account, project: projects[2]),
      ]
      adr = adrs[-1]
      adrs << create(:adr, :accepted, account: db_download.account, refines_adr_id: adr.id, project: projects[2])
      adrs << create(:adr, :accepted, account: db_download.account, replaced_by_adr_id: adr.id, project: projects[2])

      download = Download.new(download: db_download)

      download.assemble
      db_download.reload

      expect(download.ready?).to eq(true)
      expect(download.data_ready_at).to be_within(10).of(Time.now)
      expect(download.delete_at).to be_within(10).of(Time.now + (60 * 60 * 24))

      doc = REXML::Document.new(download.all_data.strip)
      expect(doc[0].name).to eq("html")
      html = doc[0]
      expect(html.class).to eq(REXML::Element)
      expect(html.name).to eq("html")
      expect(html.length).to eq(1)

      body = html[0]
      expect(body.name).to eq("body")
      expect(body.length).to eq(1)

      main = body[0]
      expect(main.name).to eq("main")
      expect(main.length).to eq(2)

      adrs_element     = main[0]
      projects_element = main[1]

      expect(adrs_element.name).to eq("section")
      expect(adrs_element[:title]).to eq("adrs")
      expect(adrs_element.length).to eq(adrs.length)
      adrs.each do |adr|
        section = adrs_element.children.detect { |child|
          child[:id] == adr.external_id
        }
        expect(section).not_to eq(nil),"Can't find #{adr.external_id} in #{adrs_element}"
        expect(section[0].name).to eq("h2")
        expect(section[0].text).to eq(adr.title)
        expect(section[1].name).to eq("dl")
        as_hash = {}
        dt = nil
        dd = nil
        section[1].children.each { |element|
          if element.name == "dt"
            if !dt.nil?
              as_hash[dt.text] = dd.text
            end
            dt = element
          elsif element.name == "dd"
            dd = element
          else
            fail "Got #{element.name} but expecting only dt and dd"
          end
        }
        hash = adr.as_json
        as_hash.each do |key,value|
          expect(value.to_s).to eq(hash[key.to_sym].to_s)
        end
      end

      expect(projects_element.name).to eq("section")
      expect(projects_element[:title]).to eq("projects")
      expect(projects_element.length).to eq(projects.length)

      projects.each do |project|
        section = projects_element.children.detect { |child|
          child[:id] == project.external_id
        }
        expect(section).not_to eq(nil),"Can't find #{project.external_id} in #{projects_element}"
        expect(section[0].name).to eq("h2")
        expect(section[0].text).to eq(project.name)
        expect(section[1].name).to eq("dl")
        as_hash = {}
        dt = nil
        dd = nil
        section[1].children.each { |element|
          if element.name == "dt"
            if !dt.nil?
              as_hash[dt.text] = dd.text
            end
            dt = element
          elsif element.name == "dd"
            dd = element
          else
            fail "Got #{element.name} but expecting only dt and dd"
          end
        }
        hash = project.as_json
        as_hash.each do |key,value|
          expect(value.to_s).to eq(hash[key.to_sym].to_s),key
        end
      end
    end
  end
end
