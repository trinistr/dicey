# frozen_string_literal: true

module Dicey
  RSpec.describe DieFoundry do
    subject(:foundry) { described_class.new }

    include_examples "has an alias", :cast, :call

    context "when called with a single positive integer" do
      let(:die) { foundry.call("6") }

      it "returns a RegularDie with the given number of sides" do
        expect(die).to be_a RegularDie
        expect(die.sides_list).to eq [1, 2, 3, 4, 5, 6]
      end

      context "with shorthand notation" do
        specify "dN produces a single RegularDie" do
          expect(foundry.call("d6")).to eq RegularDie.new(6)
          expect(foundry.call("D3")).to eq RegularDie.new(3)
        end

        specify "1dN produces an array of 1 RegularDie" do
          expect(foundry.call("1d9")).to eq [RegularDie.new(9)]
          expect(foundry.call("1D2")).to eq [RegularDie.new(2)]
        end

        specify "MdN produces an array of RegularDie" do
          expect(foundry.call("2d4")).to eq [RegularDie.new(4), RegularDie.new(4)]
          expect(foundry.call("2D6")).to eq [RegularDie.new(6), RegularDie.new(6)]
        end
      end

      context "and it's surrounded with brackets" do
        let(:die) { foundry.call("(6)") }

        it "raises DiceyError" do
          expect { die }.to raise_error DiceyError
        end
      end

      context "and it's followed by a comma" do
        let(:die) { foundry.call("6,") }

        it "returns a NumericDie with one side" do
          expect(die).to be_a NumericDie
          expect(die.sides_list).to eq [6]
        end
      end
    end

    context "when called with a single negative integer in a string" do
      let(:die) { foundry.call("-6") }

      it "raises DiceyError" do
        expect { die }.to raise_error DiceyError
      end
    end

    context "when called with a single 0 in a string" do
      let(:die) { foundry.call("0") }

      it "raises DiceyError" do
        expect { die }.to raise_error DiceyError
      end
    end

    context "when called with a list of integers" do
      let(:die) { foundry.call("1,3,19") }

      it "returns a NumericDie with the given sides" do
        expect(die).to be_a NumericDie
        expect(die.sides_list).to eq [1, 3, 19]
      end

      context "if list is surrounded with brackets" do
        let(:die) { foundry.call("(1,3,19)") }

        it "strips them before processing" do
          expect(die).to be_a NumericDie
          expect(die.sides_list).to eq [1, 3, 19]
        end
      end

      context "and it's followed by a comma" do
        let(:die) { foundry.call("1,3,19,") }

        it "returns a NumericDie with the given sides" do
          expect(die).to be_a NumericDie
          expect(die.sides_list).to eq [1, 3, 19]
        end
      end

      context "with shorthand notation" do
        specify "dS produces a single NumericDie" do
          expect(foundry.call("d3,4")).to eq NumericDie.new([3, 4])
          expect(foundry.call("D4,3")).to eq NumericDie.new([4, 3])
        end

        specify "1dS produces an array of 1 NumericDie" do
          expect(foundry.call("1d-1,0,1")).to eq [NumericDie.new([-1, 0, 1])]
          expect(foundry.call("1D3,4,27")).to eq [NumericDie.new([3, 4, 27])]
        end

        specify "MdS produces an array of NumericDie" do
          expect(foundry.call("2d1,")).to eq [NumericDie.new([1]), NumericDie.new([1])]
          expect(foundry.call("3D0,")).to eq(
            [NumericDie.new([0]), NumericDie.new([0]), NumericDie.new([0])]
          )
        end
      end
    end

    context "when called with a list of decimal numbers" do
      let(:die) { foundry.call("1.5,-3.5,19.5") }

      it "returns a NumericDie with the given sides" do
        expect(die).to be_a NumericDie
        expect(die.sides_list).to eq [1.5, -3.5, 19.5]
        expect(die.sides_list).to all be_a Rational
      end

      context "if list includes integers" do
        let(:die) { foundry.call("1.5,-3,19.5") }

        it "returns a NumericDie with both Rationals and Integers" do
          expect(die).to be_a NumericDie
          expect(die.sides_list).to eq [1.5, -3, 19.5]
          expect(die.sides_list).to all be_a(Rational).or be_an(Integer)
        end
      end

      context "if list is surrounded with brackets" do
        let(:die) { foundry.call("(1.5,-3.5,19.5)") }

        it "strips them before processing" do
          expect(die).to be_a NumericDie
          expect(die.sides_list).to eq [1.5, -3.5, 19.5]
          expect(die.sides_list).to all be_a Rational
        end
      end

      context "and it's followed by a comma" do
        let(:die) { foundry.call("1.5,-3.5,19.5,") }

        it "returns a NumericDie with the given sides" do
          expect(die).to be_a NumericDie
          expect(die.sides_list).to eq [1.5, -3.5, 19.5]
          expect(die.sides_list).to all be_a Rational
        end
      end

      context "with shorthand notation" do
        specify "dS produces a single NumericDie" do
          expect(foundry.call("d3.0,4")).to eq NumericDie.new([3.0, 4])
          expect(foundry.call("D4,0.5")).to eq NumericDie.new([4, 0.5])
        end

        specify "1dS produces an array of 1 NumericDie" do
          expect(foundry.call("1d(-1.0,0,1)")).to eq [NumericDie.new([-1.0, 0, 1])]
          expect(foundry.call("1D3,4,-0.5")).to eq [NumericDie.new([3, 4, -0.5])]
        end

        specify "MdS produces an array of NumericDie" do
          expect(foundry.call("2d1.0,")).to eq [NumericDie.new([1.0]), NumericDie.new([1.0])]
          expect(foundry.call("3D0.0,")).to eq(
            [NumericDie.new([0.0]), NumericDie.new([0.0]), NumericDie.new([0.0])]
          )
        end
      end

      context "when called with a single decimal number" do
        let(:die) { foundry.call("0.5") }

        it "raises DiceyError" do
          expect { die }.to raise_error DiceyError
        end
      end
    end

    context "when called with a range" do
      let(:die) { foundry.call("5-15") }

      it "returns a NumericDie with the given sides" do
        expect(die).to be_a NumericDie
        expect(die.sides_list).to eq (5..15).to_a
      end

      context "when is separator is not '-'" do
        let(:die) { foundry.call("5#{sep}7") }
        let(:sep) { %w[– — .. ... …].sample }

        it "returns a NumericDie with the given sides" do
          expect(die).to be_a NumericDie
          expect(die.sides_list).to eq (5..7).to_a
        end
      end

      context "if ends are reversed" do
        let(:die) { foundry.call("15-5") }

        it "returns a NumericDie with the given sides in ascending order" do
          expect(die).to be_a NumericDie
          expect(die.sides_list).to eq (5..15).to_a
        end
      end

      context "if either end is non-integer" do
        let(:die) { foundry.call(["5.5-15", "5-15.0"].sample) }

        it "raises DiceyError" do
          expect { die }.to raise_error DiceyError
        end
      end

      context "with shorthand notation" do
        specify "dS produces a single NumericDie" do
          expect(foundry.call("d3-5")).to eq NumericDie.new([3, 4, 5])
          expect(foundry.call("D4..6")).to eq NumericDie.new([4, 5, 6])
        end

        specify "1dS produces an array of 1 NumericDie" do
          expect(foundry.call("1d(-1—1)")).to eq [NumericDie.new([-1, 0, 1])]
          expect(foundry.call("1D3-5")).to eq [NumericDie.new([3, 4, 5])]
        end

        specify "MdS produces an array of NumericDie" do
          expect(foundry.call("2d1-1")).to eq [NumericDie.new([1]), NumericDie.new([1])]
          expect(foundry.call("3D0…0")).to eq(
            [NumericDie.new([0]), NumericDie.new([0]), NumericDie.new([0])]
          )
        end
      end
    end

    context "when called with a non-number" do
      let(:die) { foundry.call("a") }

      it "raises DiceyError" do
        expect { die }.to raise_error DiceyError
      end
    end
  end
end
