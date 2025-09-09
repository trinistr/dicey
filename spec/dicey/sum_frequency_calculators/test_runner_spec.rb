# frozen_string_literal: true

module Dicey
  RSpec.describe SumFrequencyCalculators::TestRunner do
    subject(:call_result) do
      described_class.new.call(dice, roll_calculators: calculators, report_style: :full)
    end

    let(:dice) { %w[2d2 -2] }
    let(:calculators) { [SumFrequencyCalculators::BruteForce.new] }

    before { stub_const("Dicey::SumFrequencyCalculators::TestRunner::TEST_DATA", [[[1], { 1 => 1 }]]) }

    it "returns true if all tests pass" do
      expect { call_result }.to output(<<~TEXT).to_stdout
        ⚀:
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
          ⚀:
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
          ⚀:
            #{custom_calculator}: ✘ 🠐 failure!
            Dicey::SumFrequencyCalculators::BruteForce: ✔
        TEXT
        expect(call_result).to be false
      end
    end
  end
end
