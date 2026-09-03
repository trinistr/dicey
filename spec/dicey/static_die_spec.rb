# frozen_string_literal: true

module Dicey
  RSpec.describe StaticDie do
    describe ".new" do
      subject(:die) { described_class.new(value) }
      let(:value) { [5, -3.2, "ABC"].sample }

      it "makes a die with single value" do
        expect(die.sides_list).to be_frozen
        expect(die.sides_list).to eq [value]
      end

      it "treats array as a single value" do
        expect(described_class.new([1, 2, 3]).sides_list).to eq [[1, 2, 3]]
      end
    end

    describe "#value" do
      subject(:value) { die.value }

      let(:die) { described_class.new(init_value) }
      let(:init_value) { [5, -3.2, "ABC"].sample }

      it "returns the value" do
        expect(value).to eq init_value
      end
    end

    include_examples "has an alias", :current, :value
    include_examples "has an alias", :next, :value
    include_examples "has an alias", :roll, :value

    describe "#to_s" do
      subject(:text) { described_class.new(value).to_s }

      context "with a positive value" do
        let(:value) { [5, VectorNumber["A"], "ABC"].sample }

        it "returns the value prefixed with '+'" do
          expect(text).to eq "+#{value}"
        end
      end

      context "with a negative value" do
        let(:value) { [-3.2, -VectorNumber["A"]].sample }

        it "returns the value as string (prefixed with '-' by default)" do
          expect(text).to eq value.to_s
        end
      end

      context "with 0" do
        let(:value) { 0 }

        it "returns '0'" do
          expect(text).to eq "0"
        end
      end
    end
  end
end
