# frozen_string_literal: true

module Dicey
  RSpec.describe SumFrequencyCalculators::BruteForce do
    subject(:calculator) { described_class.new }
    let(:dice) do
      [
        Dicey::NumericDie.new([0.1, 0.2, 0.3]),
        Dicey::NumericDie.new([-1, -5]),
        Dicey::RegularDie.new(3),
      ]
    end

    it "rejects non-numeric dice" do
      dice << Dicey::AbstractDie.new(%w[s n a k e])
      expect { calculator.call(dice) }.to raise_error(Dicey::DiceyError)
    end

    context "when called with an empty list of dice" do
      it "returns an empty hash" do
        expect(calculator.call([])).to eq({})
      end
    end

    context "when called with no-overlap dice" do
      it "calculates frequencies correctly" do
        expect(calculator.call(dice)).to eq({
          -3.9 => 1,
          -3.8 => 1,
          -3.7 => 1,
          -2.9 => 1,
          -2.8 => 1,
          -2.7 => 1,
          -1.9 => 1,
          -1.8 => 1,
          -1.7 => 1,
          0.1 => 1,
          0.2 => 1,
          0.3 => 1,
          1.1 => 1,
          1.2 => 1,
          1.3 => 1,
          2.1 => 1,
          2.2 => 1,
          2.3 => 1,
        })
      end
    end

    context "when called with overlap dice" do
      before { dice[0] = Dicey::RegularDie.new(2) }

      it "calculates frequencies correctly" do
        expect(calculator.call(dice)).to eq({
          -3 => 1,
          -2 => 2,
          -1 => 2,
          0 => 1,
          1 => 1,
          2 => 2,
          3 => 2,
          4 => 1,
        })
      end
    end
  end
end
