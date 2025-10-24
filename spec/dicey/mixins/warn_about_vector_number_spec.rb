# frozen_string_literal: true

module Dicey
  RSpec.describe Mixins::WarnAboutVectorNumber do
    include described_class

    subject(:warning) { warn_about_vector_number }

    it "warns about missing VectorNumber gem and returns false" do
      expect { warning }.to output(/gem "vector_number"/).to_stderr
      expect(warning).to be false
    end
  end
end
