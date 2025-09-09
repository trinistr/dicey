# frozen_string_literal: true

RSpec.describe "Running built-in tests via CLI" do
  require "dicey/cli/blender"

  subject(:blender_call) { Dicey::CLI::Blender.new.call(arguments) }

  let(:arguments) { %w[--test full] }

  it "exits with true" do
    expect(blender_call).to be true
  end
end
