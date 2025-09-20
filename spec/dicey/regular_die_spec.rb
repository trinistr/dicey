# frozen_string_literal: true

module Dicey
  RSpec.describe RegularDie do
    describe ".new" do
      subject(:die) { described_class.new(max) }
      let(:max) { rand(3..12) }

      it "makes a die with sides from 1 to max" do
        expect(die.sides_list).to be_frozen
        expect(die.sides_list).to eq (1..max).to_a
      end

      it "can make a 1-sided die" do
        expect(described_class.new(1).sides_list).to eq [1]
      end

      context "if given a non-Integer" do
        it "raises DiceyError" do
          expect { described_class.new([]) }.to raise_error(DiceyError)
          expect { described_class.new("c") }.to raise_error(DiceyError)
          expect { described_class.new(nil) }.to raise_error(DiceyError)
          expect { described_class.new(1.5) }.to raise_error(DiceyError)
        end
      end

      context "if given a non-positive Integer" do
        it "raises DiceyError" do
          expect { described_class.new(0) }.to raise_error(DiceyError)
          expect { described_class.new(-1) }.to raise_error(DiceyError)
        end
      end
    end

    describe "#to_s" do
      subject(:text) { described_class.new(max).to_s }
      let(:max) { rand(1..12) }

      it "returns Dmax" do
        expect(text).to eq "D#{max}"
      end
    end
  end
end
