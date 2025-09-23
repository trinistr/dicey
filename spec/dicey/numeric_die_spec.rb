# frozen_string_literal: true

module Dicey
  RSpec.describe NumericDie do
    describe ".new" do
      subject(:die) { described_class.new(sides) }
      let(:sides) { Array.new(rand(3..12)) { rand } }

      context "when given an Array" do
        it "makes a frozen copy of the list of sides" do
          expect(die.sides_list).to be_frozen

          expect(die.sides_list).to eq sides
          sides << 13.13
          expect(die.sides_list).to eq sides[0...-1]
        end

        context "if list of sides contains non-numerical values" do
          it "raises DiceyError" do
            expect { described_class.new([1, 2, 3, "a", "b", "c"]) }.to raise_error(DiceyError)
            expect { described_class.new("a".."c") }.to raise_error(DiceyError)
          end
        end

        context "if list of sides is empty" do
          it "raises DiceyError" do
            expect { described_class.new([]) }.to raise_error(DiceyError)
          end
        end
      end

      context "when given a Range" do
        let(:sides) { (1..5) }

        it "transforms it into an Array" do
          expect(die.sides_list).to eq [1, 2, 3, 4, 5]
          expect(die.sides_list).to be_frozen
        end

        context "if range is non-integer" do
          it "raises DiceyError" do
            expect { described_class.new(1.5..5) }.to raise_error(DiceyError)
            expect { described_class.new(1..5.5) }.to raise_error(DiceyError)
          end
        end

        context "if range is non-numeric" do
          it "raises DiceyError" do
            expect { described_class.new("a".."c") }.to raise_error(DiceyError)
          end
        end
      end
    end
  end
end
