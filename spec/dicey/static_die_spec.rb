# frozen_string_literal: true

module Dicey
  RSpec.describe StaticDie do
    let(:die) { described_class.new(value) }

    let(:value) { [5, -3.2, "ABC"].sample }

    describe ".new" do
      it "makes a die with single value" do
        expect(die.sides_list).to be_frozen
        expect(die.sides_list).to eq [value]
      end

      it "treats array as a single value" do
        expect(described_class.new([1, 2, 3]).sides_list).to eq [[1, 2, 3]]
      end
    end

    describe "#value" do
      it "returns the value" do
        expect(die.value).to eq value
      end
    end

    describe "#current" do
      it "always returns #value" do
        expect(die.current).to eq value
        die.next
        expect(die.current).to eq value
      end
    end

    describe "#next" do
      it "always returns #value" do
        expect(die.next).to eq value
        expect(die.next).to eq value
      end
    end

    describe "#roll" do
      it "always returns #value" do
        expect(die.roll).to eq value
        expect(die.roll).to eq value
      end

      it "does not advance RNG" do
        seed = Random.new_seed
        other_die = AbstractDie.new([1, 2, 3])

        AbstractDie.srand(seed)
        first_roll = other_die.roll
        second_roll = other_die.roll

        AbstractDie.srand(seed)
        die.roll
        expect(other_die.roll).to eq first_roll
        die.roll
        expect(other_die.roll).to eq second_roll
      end
    end

    describe "#to_s" do
      subject(:text) { die.to_s }

      context "with a positive numeric-like value" do
        let(:value) { [5, VectorNumber["A"], 5.5].sample }

        it "returns the value prefixed with '+'" do
          expect(text).to eq "+#{value}"
        end
      end

      context "with a negative numric-like value" do
        let(:value) { [-3.2, -VectorNumber["A"], -1].sample }

        it "returns the value as string (prefixed with '-' by default)" do
          expect(text).to eq value.to_s
        end
      end

      context "with 0" do
        let(:value) { 0 }

        it "returns '+0'" do
          expect(text).to eq "+0"
        end
      end

      context "with a string" do
        let(:value) { "A'BC" }

        it "returns the value in quotes prefixed with +" do
          expect(text).to eq %(+"A'BC")
        end
      end

      context "with other values" do
        let(:value) { [[1], { a: 1 }, Object.new, :"123"].sample }

        it "returns the value prefixed with +" do
          expect(text).to eq "+#{value}"
        end
      end
    end
  end
end
