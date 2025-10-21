# frozen_string_literal: true

module Dicey
  RSpec.describe Mixins::WarnAboutVectorNumber do
    include described_class

    it "warns about missing VectorNumber gem" do
      expect { warn_about_vector_number }.to output(/gem "vector_number"/).to_stderr
    end
  end
end
