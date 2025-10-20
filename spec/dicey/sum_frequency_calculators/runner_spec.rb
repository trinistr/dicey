# frozen_string_literal: true

module Dicey
  RSpec.describe SumFrequencyCalculators::Runner do
    subject(:call_result) { described_class.new.call(dice, format: format, result: result) }

    let(:dice) { %w[2d2 1,5,] } # rubocop:disable Lint/PercentStringArray
    let(:calculators) { [SumFrequencyCalculators::KroneckerSubstitution.new] }
    let(:format) { CLI::Formatters::JSONFormatter.new }
    let(:result) { :frequencies }

    before { stub_const("Dicey::SumFrequencyCalculators::AutoSelector::AVAILABLE_CALCULATORS", calculators) }

    it "returns a formatted string with dice description and calculation result" do
      expect(call_result).to eq <<~TEXT.chomp
        {"description":"D2+D2+(1,5)","results":{"3":1,"4":2,"5":1,"7":1,"8":2,"9":1}}
      TEXT
    end

    context "if no dice are given" do
      let(:dice) { [] }

      it "raises DiceyError" do
        expect { call_result }.to raise_error(DiceyError)
      end
    end

    context "if calculators can't handle the dice" do
      let(:dice) { %w[-1,0.5 2D3] }

      it "raises DiceyError" do
        expect { call_result }.to raise_error(DiceyError)
      end
    end
  end
end
