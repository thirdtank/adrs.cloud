require "spec_helper"
require "front_end/app_view_helpers"

RSpec.describe AppViewHelpers do
  subject(:has_helpers) { Object.new.extend(described_class) }
  describe "#public_adr_path" do
    it "raises on a non-public ADR" do
      adr = create(:adr, public_id: nil)
      expect {
        has_helpers.public_adr_path(adr)
      }.to raise_error(Brut::BackEnd::Errors::Bug)
    end
  end

end
