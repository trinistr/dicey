# frozen_string_literal: true

module Dicey
  RSpec.describe AbstractDie do
    subject(:die) { described_class.new(sides) }
    let(:sides) { Array.new(rand(3..12)) { rand } }

    let(:custom_die_class) do
      Class.new(described_class) { def to_s = sides_list.join("-") }
    end

    describe ".rand" do
      it "returns a random number" do
        expect(described_class.rand).to be_between(0, 1)
        expect(described_class.rand(3)).to be_between(0, 2)
        expect(described_class.rand(5...10)).to be_between(5, 9)
      end
    end

    describe ".srand" do
      it "sets the random seed for reproducible results" do
        described_class.srand(493_525)
        numbers = Array.new(10) { described_class.rand }

        described_class.srand(493_525)
        new_numbers = Array.new(10) { described_class.rand }
        expect(new_numbers).to eq numbers
      end
    end

    context "when a descendant class uses .rand/.srand" do
      it "uses the same randomizer instance" do
        described_class.srand(255_394)
        numbers = Array.new(10) { described_class.rand }

        custom_die_class.srand(255_394)
        new_numbers = Array.new(5) { custom_die_class.rand } + Array.new(5) { described_class.rand }
        expect(new_numbers).to eq numbers
      end
    end

    describe ".describe" do
      subject(:description) { described_class.describe(dice) }

      context "when called with one die" do
        let(:dice) { described_class.new([5, 5, 0.5]) }

        it "returns a string description of the die" do
          expect(description).to eq "(5,5,0.5)"
        end
      end

      context "when called with one die in a list" do
        let(:dice) { [described_class.new([-1, -0.9, 0.1])] }

        it "returns a string description of the die" do
          expect(description).to eq "(-1,-0.9,0.1)"
        end
      end

      context "when called with multiple dice" do
        let(:dice) { [described_class.new([5, 5, 0.5]), described_class.new([1, 2, 3])] }

        it "returns a string description of the dice in the order provided" do
          expect(description).to eq "(5,5,0.5);(1,2,3)"
        end
      end

      context "when called with different die classes" do
        let(:dice) { [custom_die_class.new([5, 5, 0.5]), described_class.new([1, 2, 3])] }

        it "returns a concatenated list of their #to_s" do
          expect(description).to eq "5-5-0.5;(1,2,3)"
        end
      end

      context "when called on a different die class" do
        subject(:description) { custom_die_class.describe(dice) }

        let(:dice) { [described_class.new([5, 5, 0.5]), custom_die_class.new([1, 2, 3])] }

        it "returns a string description of the dice in the order provided" do
          expect(description).to eq "(5,5,0.5);1-2-3"
        end
      end

      context "when called with a non-Array list" do
        let(:dice) { [described_class.new([5, 5, 0.5])].each + [described_class.new([1, 2, 3])] }

        it "works the same as with an Array" do
          expect(description).to eq "(5,5,0.5);(1,2,3)"
        end
      end
    end

    describe ".new" do
      it "makes a frozen copy of the list of sides" do
        expect(die.sides_list).to be_frozen

        expect(die.sides_list).to eq sides
        sides << 13.13
        expect(die.sides_list).to eq sides[0...-1]
      end

      it "allows any kinds of sides" do
        cool_die = described_class.new([1, 2, 3, "a", "b", "c"])
        expect(cool_die.sides_list).to eq [1, 2, 3, "a", "b", "c"]
      end

      context "if given a Range" do
        let(:sides) { ("a".."c") }

        it "transforms it into an Array" do
          expect(die.sides_list).to eq %w[a b c]
          expect(die.sides_list).to be_frozen
        end
      end

      context "if the list of sides is empty" do
        it "raises DiceyError" do
          expect { described_class.new([]) }.to raise_error(DiceyError)
        end
      end
    end

    describe "#sides_list" do
      it "returns the list of sides" do
        expect(die.sides_list).to eq sides
      end
    end

    describe "#sides_num" do
      it "returns the number of sides" do
        expect(die.sides_num).to eq sides.size
      end
    end

    describe "#current" do
      it "returns the current value, without advancing the die" do
        expect(die.current).to be sides.first
        # For good measure
        expect(die.current).to be sides.first
      end
    end

    describe "#next" do
      it "returns the current value, advancing the die" do
        expect(die.next).to be sides[0]
        expect(die.current).to be sides[1]
        expect(die.next).to be sides[1]
        expect(die.current).to be sides[2]
      end

      it "wraps around the die" do
        (die.sides_num + 2).times { die.next }
        expect(die.current).to be sides[2]
      end
    end

    describe "#roll" do
      subject(:rolled_side) { die.roll }

      it "returns a random side, advancing the die to it" do
        expect(sides).to include rolled_side
        expect(die.current).to be rolled_side
      end

      it "uses class's .rand for reproducible results" do
        seed = rand

        die.class.srand(seed)
        roll = die.class.new(sides).roll

        die.class.srand(seed)
        expect(rolled_side).to be roll
      end
    end

    describe "#to_s" do
      it "returns a bracketed list of die's sides" do
        expect(die.to_s).to eq "(#{sides.join(",")})"
      end
    end

    describe "#==" do
      it "returns true if the other die has the same list of sides, irrespective of class" do
        expect(die == custom_die_class.new(sides)).to be true
      end

      it "returns false if the other die has a different list of sides" do
        expect(die == described_class.new(sides + [1])).to be false
      end
    end

    describe "#eql?" do
      it "returns true if the other die has the same list of sides and the same class" do
        expect(die.eql?(described_class.new(sides))).to be true
      end

      it "returns false if the other die has the same list of sides but different class" do
        expect(die.eql?(custom_die_class.new(sides))).to be true
      end

      it "returns false if the other die has a different list of sides" do
        expect(die.eql?(described_class.new(sides + [1]))).to be false
      end
    end

    describe "#hash" do
      it "returns the same hash as for a die with the same list of sides and the same class" do
        expect(die.hash).to eq described_class.new(sides).hash
      end

      it "returns different hash than for a die with the same list of sides but different class" do
        expect(die.hash).not_to eq custom_die_class.new(sides).hash
      end

      it "returns different hash than for a die with a different list of sides" do
        expect(die.hash).not_to eq described_class.new(sides + [1]).hash
      end
    end
  end
end
