require "spec_helper"
require "back_end/actions/adrs/tag_serializer"

RSpec.describe Actions::Adrs::TagSerializer do
  subject(:serializer) { described_class.new }

  describe "#from_array" do
    it "joins the tags with commas" do
      expect(serializer.from_array(["foo", "bar", "blah"])).to eq("foo, bar, blah")
    end
  end

  describe "#from_string" do
    it "splits on newlines and commas, strips whitespace, ignores dupes, and downcases" do
      expect(serializer.from_string(%{
foo, BAr
BLAh, foo
   quuux, })).to eq(["foo", "bar", "blah", "quuux" ])
    end
  end

end
