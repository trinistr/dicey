# frozen_string_literal: true

module Dicey
  RSpec.describe DieFoundry do
    subject(:foundry) { described_class.new }

    include_examples "has an alias", :cast, :call

    context "when called with a single positive integer in a string" do
      let(:die) { foundry.call("6") }

      it "returns a RegularDie with the given number of sides" do
        expect(die).to be_a RegularDie
        expect(die.sides_list).to eq [1, 2, 3, 4, 5, 6]
      end

      context "and it's surrounded with brackets" do
        let(:die) { foundry.call("(6)") }

        it "returns a NumericDie with one side" do
          expect(die).to be_a NumericDie
          expect(die.sides_list).to eq [6]
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

      it "returns a NumericDie with one side" do
        expect(die).to be_a NumericDie
        expect(die.sides_list).to eq [-6]
      end
    end

    context "when called with a single 0 in a string" do
      let(:die) { foundry.call("0") }

      it "returns a NumericDie with one side" do
        expect(die).to be_a NumericDie
        expect(die.sides_list).to eq [0]
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
    end

    context "when called with a list of real numbers" do
      let(:die) { foundry.call("1.5,-3.5,19.5") }

      it "returns a NumericDie with the given sides" do
        expect(die).to be_a NumericDie
        expect(die.sides_list).to eq [1.5, -3.5, 19.5]
      end

      context "if list is surrounded with brackets" do
        let(:die) { foundry.call("(1.5,-3.5,19.5)") }

        it "strips them before processing" do
          expect(die).to be_a NumericDie
          expect(die.sides_list).to eq [1.5, -3.5, 19.5]
        end
      end

      context "and it's followed by a comma" do
        let(:die) { foundry.call("1.5,-3.5,19.5,") }

        it "returns a NumericDie with the given sides" do
          expect(die).to be_a NumericDie
          expect(die.sides_list).to eq [1.5, -3.5, 19.5]
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
