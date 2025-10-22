# frozen_string_literal: true

require "dicey/cli/calculator_test_runner"

module Dicey
  RSpec.describe CLI::CalculatorTestRunner do
    subject(:call_result) { described_class.new.call(dice, report_style: :full) }

    let(:dice) { %w[2d2 -2] }
    let(:calculators) { [DistributionCalculators::BruteForce.new] }

    before do
      stub_const("#{described_class}::TEST_DATA", [[[1], { 1 => 1 }]])
      stub_const("#{described_class}::AVAILABLE_CALCULATORS", calculators)
    end

    it "returns true if all tests pass" do
      expect { call_result }.to output(<<~TEXT).to_stdout
        D1:
          Dicey::DistributionCalculators::BruteForce: ✔
      TEXT
      expect(call_result).to be true
    end

    context "if a calculator raises an error" do
      let(:calculators) { [custom_calculator.new, DistributionCalculators::BruteForce.new] }

      let(:custom_calculator) do
        Class.new(DistributionCalculators::BaseCalculator) do
          def call(*)
            raise DiceyError, "oh no!"
          end
        end
      end

      it "returns false, printing warning text" do
        expect { call_result }.to output(<<~TEXT).to_stdout
          D1:
            #{custom_calculator}: ⛐ 🠐 crash!
            Dicey::DistributionCalculators::BruteForce: ✔
        TEXT
        expect(call_result).to be false
      end
    end

    context "if a calculator returns unexpected results" do
      let(:calculators) { [custom_calculator.new, DistributionCalculators::BruteForce.new] }

      let(:custom_calculator) do
        Class.new(DistributionCalculators::BaseCalculator) do
          def call(*) = { 1 => 2 }
        end
      end

      it "returns false, printing warning text" do
        expect { call_result }.to output(<<~TEXT).to_stdout
          D1:
            #{custom_calculator}: ✘ 🠐 failure!
            Dicey::DistributionCalculators::BruteForce: ✔
        TEXT
        expect(call_result).to be false
      end
    end
  end
end
