# frozen_string_literal: true

RSpec.describe "Running built-in tests via CLI" do
  require "dicey/cli/blender"

  subject(:blender) { Dicey::CLI::Blender.new }

  it "exits with true, showing successful test run" do
    expect(blender.call(%w[--test quiet])).to be true
  end

  it "outputs test results" do
    expect { blender.call(%w[--test]) }.to output(a_string_including(<<~TEXT)).to_stdout
      D1:
        Dicey::SumFrequencyCalculators::KroneckerSubstitution: ✔
        Dicey::SumFrequencyCalculators::MultinomialCoefficients: ✔
        Dicey::SumFrequencyCalculators::BruteForce: ✔
    TEXT
  end
end
