# frozen_string_literal: true

module Dicey
  RSpec.describe Roller do
    subject(:result) { described_class.new.call(dice, format: format) }

    let(:dice) { %w[2 (1,5) 2D3] }
    let(:format) { OutputFormatters::ListFormatter.new }

    it "returns a formatted string with dice description and roll result" do
      expect(result).to match(/\A# D2\+\(1,5\)\+D3\+D3\nroll => (?:[4-9]|1[0-3])\n\z/)
    end

    context "if no dice are given" do
      let(:dice) { [] }

      it "raises DiceyError" do
        expect { result }.to raise_error(DiceyError)
      end
    end
  end
end
