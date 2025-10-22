# frozen_string_literal: true

RSpec.describe "Running built-in tests via CLI" do
  require "dicey/cli"

  subject(:test_run) { Dicey::CLI.call(%w[--test]) }

  it "exits with true and outputs test results" do
    expect { test_run }.to output(/\A#{<<~TEXT}.+^\(s,a,4\)\+\(s,a,4\):/m).to_stdout
      D1:
        Dicey::DistributionCalculators::Trivial: ✔
        Dicey::DistributionCalculators::PolynomialConvolution: ✔
        Dicey::DistributionCalculators::MultinomialCoefficients: ✔
        Dicey::DistributionCalculators::Iterative: ✔
    TEXT
    expect(test_run).to be true
  end

  context "if vector_number is not available" do
    before do
      hide_const("VectorNumber")
      stub_const("Dicey::CLI::CalculatorTestRunner::TEST_DATA", Dicey::CLI::CalculatorTestRunner::TEST_DATA[...-3])
    end

    it "completes successfully, skipping non-numeric dice tests" do
      expect { test_run }.not_to output(a_string_including("(s,a,4)+(s,a,4):")).to_stdout
      expect(test_run).to be true
    end
  end

  context "with 'quiet' report" do
    subject(:test_run) { Dicey::CLI.call(%w[--test quiet]) }

    it "doesn't output anything" do
      expect { test_run }.not_to output.to_stdout
      expect(test_run).to be true
    end
  end
end
