# frozen_string_literal: true

RSpec.describe Dicey do
  it "has a valid version number" do
    expect(described_class::VERSION).not_to be nil
    expect { Gem::Version.new(described_class::VERSION) }.not_to raise_error
  end
end
