require_relative "../spec_support"
module Brut
  module Backend
    class SeedData
      def self.inherited(seed_data_klass)
        @classes ||= []
        @classes << seed_data_klass
      end
      def self.classes = @classes || []

      def setup!
        Brut::SpecSupport::FactoryBot.new.setup!
      end

      def load_seeds!
        DB.transaction do
          self.class.classes.each do |klass|
            klass.new.seed!
          end
        end
      end
    end
  end
end
