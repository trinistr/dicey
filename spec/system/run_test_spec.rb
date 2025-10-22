# frozen_string_literal: true

RSpec.describe "Running built-in tests via CLI" do
  require "dicey/cli"

  subject(:test_run) { Dicey::CLI.call(%w[--test]) }

  it "exits with true and outputs test results" do
    expect { test_run }.to output(a_string_including(<<~TEXT)).to_stdout
      D1:
        Dicey::DistributionCalculators::PolynomialConvolution: ✔
        Dicey::DistributionCalculators::MultinomialCoefficients: ✔
        Dicey::DistributionCalculators::BruteForce: ✔
    TEXT
    expect(test_run).to be true
  end

  context "if vector_number is not available" do
    before { hide_const("VectorNumber") }

    it "completes successfully, skipping non-numeric dice tests" do
      # In reality, this won't be printed, as these test cases wouldn't be added at all.
      # But here we work with initially available VectorNumber, which then disappears.
      expect { test_run }.to(
        output(/"vector_number"/).to_stderr
        .and(output(a_string_including(<<~TEXT)).to_stdout)
          (s,a,4)+(s,a,4):
            Dicey::DistributionCalculators::PolynomialConvolution: ☂
            Dicey::DistributionCalculators::MultinomialCoefficients: ☂
            Dicey::DistributionCalculators::BruteForce: ☂
        TEXT
      )
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
