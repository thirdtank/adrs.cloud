module Brut::SpecSupport::GeneralSupport
  def self.included(mod)
    mod.extend(ClassMethods)
  end

  module ClassMethods
    def implementation_is_trivial
      it "has no tests because the implementation is trivial" do
        expect(true).to eq(true)
      end
    end
  end
end
