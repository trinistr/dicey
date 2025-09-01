# frozen_string_literal: true

RSpec.describe "Running built-in tests via CLI" do
  it "exits with true" do
    require "dicey/cli/blender"
    expect(Dicey::CLI::Blender.new.call(["--test", "quiet"])).to be true
  end
end
