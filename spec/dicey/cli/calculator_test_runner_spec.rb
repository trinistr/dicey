# frozen_string_literal: true

require "dicey/cli/calculator_test_runner"

module Dicey
  RSpec.describe CLI::CalculatorTestRunner do
    subject(:call_result) { described_class.new.call(dice, report_style: :full) }

    let(:dice) { %w[2d2 -2] }
    let(:calculators) { [SumFrequencyCalculators::BruteForce.new] }

    before do
      stub_const("Dicey::CLI::CalculatorTestRunner::TEST_DATA", [[[1], { 1 => 1 }]])
      stub_const("Dicey::CLI::CalculatorTestRunner::AVAILABLE_CALCULATORS", calculators)
    end

    it "returns true if all tests pass" do
      expect { call_result }.to output(<<~TEXT).to_stdout
        D1:
          Dicey::SumFrequencyCalculators::BruteForce: ✔
      TEXT
      expect(call_result).to be true
    end

    context "if a calculator raises an error" do
      let(:calculators) { [custom_calculator.new, SumFrequencyCalculators::BruteForce.new] }

      let(:custom_calculator) do
        Class.new(SumFrequencyCalculators::BaseCalculator) do
          def call(*)
            raise DiceyError, "oh no!"
          end
        end
      end

      it "returns false, printing warning text" do
        expect { call_result }.to output(<<~TEXT).to_stdout
          D1:
            #{custom_calculator}: ⛐ 🠐 crash!
            Dicey::SumFrequencyCalculators::BruteForce: ✔
        TEXT
        expect(call_result).to be false
      end
    end

    context "if a calculator returns unexpected results" do
      let(:calculators) { [custom_calculator.new, SumFrequencyCalculators::BruteForce.new] }

      let(:custom_calculator) do
        Class.new(SumFrequencyCalculators::BaseCalculator) do
          def call(*) = { 1 => 2 }
        end
      end

      it "returns false, printing warning text" do
        expect { call_result }.to output(<<~TEXT).to_stdout
          D1:
            #{custom_calculator}: ✘ 🠐 failure!
            Dicey::SumFrequencyCalculators::BruteForce: ✔
        TEXT
        expect(call_result).to be false
      end
    end
  end
end
