# frozen_string_literal: true

module Dicey
  RSpec.describe SumFrequencyCalculators::AutoSelector do
    subject(:selected_calculator) { selector.call(dice) }

    let(:selector) { described_class.new }

    context "with a small list of large regular dice" do
      let(:dice) { RegularDie.from_count(2, 600) }

      it "returns KroneckerSubstitution" do
        expect(selected_calculator).to be_a SumFrequencyCalculators::KroneckerSubstitution
      end
    end

    context "with a large list of small regular dice" do
      let(:dice) { RegularDie.from_count(800, 2) }

      it "returns MultinomialCoefficients" do
        expect(selected_calculator).to be_a SumFrequencyCalculators::MultinomialCoefficients
      end
    end

    context "with a large list of small irregular dice" do
      let(:dice) { NumericDie.from_list([1, 2, 3], [3, 5, 6]) }

      it "returns KroneckerSubstitution" do
        expect(selected_calculator).to be_a SumFrequencyCalculators::KroneckerSubstitution
      end
    end

    context "with a small list of small numeric dice" do
      let(:dice) { RegularDie.from_count(2, 2) }

      it "returns KroneckerSubstitution" do
        # Check that we don't accidentally pick BruteForce due to small heuristic complexity.
        expect(selected_calculator).to be_a SumFrequencyCalculators::KroneckerSubstitution
      end
    end

    context "with a list of non-numeric dice" do
      let(:dice) { [AbstractDie.new([1, "a", :c])] }

      it "returns BruteForce" do
        expect(selected_calculator).to be_a SumFrequencyCalculators::BruteForce
      end

      context "when vector_number is not available" do
        before { hide_const("VectorNumber") }

        it "returns nil with a warning" do
          expect { selected_calculator }.to output.to_stderr
          expect(selected_calculator).to be nil
        end
      end
    end

    context "if initialized with a custom list of calculators" do
      let(:selector) { described_class.new([SumFrequencyCalculators::KroneckerSubstitution.new]) }
      let(:dice) { RegularDie.from_count(2, 2) }

      it "considers only the given calculators" do
        expect(selected_calculator).to be_a SumFrequencyCalculators::KroneckerSubstitution
      end

      context "if no calculators are compatible" do
        let(:dice) { [AbstractDie.new([1, "a", :c])] }

        it "returns nil" do
          expect(selected_calculator).to be nil
        end
      end
    end
  end
end
