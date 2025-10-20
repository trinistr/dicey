# frozen_string_literal: true

require "dicey/cli"

module Dicey
  RSpec.describe CLI do
    describe ".call" do
      subject(:cli_call) { described_class.call(argv) }

      let(:argv) { ["1", "2d3,4"] }
      let(:blender) { instance_double(CLI::Blender, call: true) }

      before { allow(described_class::Blender).to receive(:new).and_return(blender) }

      it "calls Blender#call" do
        expect(blender).to receive(:call).with(argv)
        expect(cli_call).to be true
      end
    end
  end
end
