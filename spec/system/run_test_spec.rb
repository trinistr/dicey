# frozen_string_literal: true

RSpec.describe "Running built-in tests via executable" do
  it "exits with 0" do
    expect(system("exe/dicey --test quiet")).to be true
  end
end
