# frozen_string_literal: true

require "dicey/cli/calculator_test_runner"

module Dicey
  RSpec.describe CLI::CalculatorTestRunner do
    subject(:call_result) { described_class.new.call(dice, report_style: report_style) }

    let(:dice) { %w[2d2 -2] }
    let(:report_style) { :full }

    let(:test_data) { [[[1], { 1 => 1 }]] }
    let(:calculators) { [DistributionCalculators::Iterative.new] }

    let(:custom_calculator) do
      Class.new(DistributionCalculators::BaseCalculator) do
        def call(*)
          raise DiceyError, "oh no!"
        end
      end
    end

    before do
      stub_const("#{described_class}::TEST_DATA", test_data)
      stub_const("#{described_class}::AVAILABLE_CALCULATORS", calculators)
    end

    it "outputs report and returns true if all tests pass" do
      expect { call_result }.to output(<<~TEXT).to_stdout
        D1:
          Dicey::DistributionCalculators::Iterative: ✔
      TEXT
      expect(call_result).to be true
    end

    context "if a calculator raises an error" do
      let(:calculators) { [custom_calculator.new, DistributionCalculators::Iterative.new] }

      it "returns false, printing warning text" do
        expect { call_result }.to output(<<~TEXT).to_stdout
          D1:
            #{custom_calculator}: ⛐ 🠐 crash!
            Dicey::DistributionCalculators::Iterative: ✔
        TEXT
        expect(call_result).to be false
      end
    end

    context "if a calculator returns unexpected results" do
      let(:calculators) { [custom_calculator.new, DistributionCalculators::Iterative.new] }

      let(:custom_calculator) do
        Class.new(DistributionCalculators::BaseCalculator) do
          def call(*) = { 1 => 2 }
        end
      end

      it "returns false, printing warning text" do
        expect { call_result }.to output(<<~TEXT).to_stdout
          D1:
            #{custom_calculator}: ✘ 🠐 failure!
            Dicey::DistributionCalculators::Iterative: ✔
        TEXT
        expect(call_result).to be false
      end
    end

    context "with report_style: :short" do
      let(:report_style) { :short }

      it "outputs short report and returns true if all tests pass" do
        expect { call_result }.to output(<<~TEXT).to_stdout
          D1: ✔
        TEXT
        expect(call_result).to be true
      end

      context "when tests fail" do
        let(:calculators) { [custom_calculator.new, DistributionCalculators::Iterative.new] }

        it "outputs short report with failures and returns false" do
          expect { call_result }.to output(<<~TEXT).to_stdout
            D1:
              #{custom_calculator}: ⛐ 🠐 crash!
          TEXT
          expect(call_result).to be false
        end
      end
    end

    context "with report_style: :quiet" do
      let(:report_style) { :quiet }

      it "outputs nothing and returns true if all tests pass" do
        expect { call_result }.not_to output.to_stdout
        expect(call_result).to be true
      end

      context "when tests fail" do
        let(:test_data) { [[[1], { 1 => 2 }]] }

        it "outputs nothing and returns false" do
          expect { call_result }.not_to output.to_stdout
          expect(call_result).to be false
        end
      end
    end
  end
end
