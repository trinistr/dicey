# frozen_string_literal: true

module Dicey
  RSpec.describe Mixins::VectorizeDice do
    include described_class

    it "ignores NumericDie instances" do
      expect(vectorize_dice([NumericDie.new([1, 2]), RegularDie.new(3)])).to eq [
        NumericDie.new([1, 2]), RegularDie.new(3),
      ]
    end

    it "vectorizes non-numeric sides of AbstractDie instances" do
      expect(vectorize_dice([AbstractDie.new(["a", "b", 3]), RegularDie.new(3)])).to eq [
        AbstractDie.new([VectorNumber.new(["a"]), VectorNumber.new(["b"]), 3]), RegularDie.new(3),
      ]
    end

    it "accepts plain dice without array" do
      expect(vectorize_dice(RegularDie.new(6))).to eq RegularDie.new(6)
      expect(vectorize_dice(NumericDie.new([1, 2]))).to eq NumericDie.new([1, 2])
      expect(vectorize_dice(AbstractDie.new([1, "a"])))
        .to eq AbstractDie.new([1, VectorNumber.new(["a"])])
    end

    context "when vector_number is not available" do
      before { hide_const("VectorNumber") }

      it "returns the original dice" do
        expect(vectorize_dice([AbstractDie.new(["a", 2]), RegularDie.new(3)])).to eq [
          AbstractDie.new(["a", 2]), RegularDie.new(3),
        ]
      end
    end
  end
end
