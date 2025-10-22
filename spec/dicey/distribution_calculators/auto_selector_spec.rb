# frozen_string_literal: true

module Dicey
  RSpec.describe DistributionCalculators::AutoSelector do
    subject(:selected_calculator) { selector.call(dice) }

    let(:selector) { described_class.new }

    context "with a small list of large regular dice" do
      let(:dice) { RegularDie.from_count(2, 600) }

      it "returns KroneckerSubstitution" do
        expect(selected_calculator).to be_a DistributionCalculators::KroneckerSubstitution
      end
    end

    context "with a large list of small regular dice" do
      let(:dice) { RegularDie.from_count(800, 2) }

      it "returns MultinomialCoefficients" do
        expect(selected_calculator).to be_a DistributionCalculators::MultinomialCoefficients
      end
    end

    context "with a small list of small irregular dice" do
      let(:dice) { NumericDie.from_list([1, 2, 3], [3, 5, 6]) }

      it "returns KroneckerSubstitution" do
        # Check that we don't accidentally pick BruteForce due to small heuristic complexity.
        expect(selected_calculator).to be_a DistributionCalculators::KroneckerSubstitution
      end
    end

    context "with a list of non-numeric dice" do
      let(:dice) { [AbstractDie.new([1, "a", :c])] }

      it "returns BruteForce" do
        expect(selected_calculator).to be_a DistributionCalculators::BruteForce
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
      let(:selector) { described_class.new([DistributionCalculators::MultinomialCoefficients.new]) }
      let(:dice) { RegularDie.from_count(2, 2) }

      it "considers only the given calculators" do
        expect(selected_calculator).to be_a DistributionCalculators::MultinomialCoefficients
      end

      context "if no calculators are compatible" do
        let(:dice) { [AbstractDie.new([1, "a", :c])] }

        it "returns nil" do
          expect(selected_calculator).to be nil
        end
      end
    end

    describe ".call" do
      subject(:selected_calculator) { described_class.call(dice) }

      let(:dice) { [] }
      let(:best_calculator) { described_class::AVAILABLE_CALCULATORS.sample }
      let(:instance) { instance_double(described_class, call: best_calculator) }

      before { stub_const("#{described_class}::INSTANCE", instance) }

      it "calls #call on the shared instance" do
        expect(described_class::INSTANCE).to receive(:call)
        expect(selected_calculator).to be best_calculator
      end
    end
  end
end
