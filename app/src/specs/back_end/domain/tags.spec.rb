require "spec_helper"
RSpec.describe Tags do
  describe "#to_s" do
    describe "::from_string" do
      it "handles spaces, commas, and newlines, returning a clean comma-separated list of tags as a string" do
        tags = Tags.from_string(string:%{foo, bar
                                blah
                                crud
                                })
        expect(tags.to_s).to eq("foo, bar, blah, crud")
      end
    end
    describe "::from_array" do
      it "returns the tags separated by commas" do
        tags = Tags.from_array(array: ["foo", "bar", "blah", "crud"])
        expect(tags.to_s).to eq("foo, bar, blah, crud")
      end
    end
  end
  describe "#to_a" do
    describe "::from_string" do
      it "handles spaces, commas, and newlines, returning an array" do
        tags = Tags.from_string(string:%{foo, bar
                                blah
                                crud
                                })
        expect(tags.to_a).to eq(["foo", "bar", "blah", "crud"])
      end
    end
    describe "::from_array" do
      it "returns the tags as they came in" do
        tags = Tags.from_array(array: ["foo", "bar", "blah", "crud"])
        expect(tags.to_a).to eq(["foo", "bar", "blah", "crud"])
      end
    end
  end
end
