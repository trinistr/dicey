# frozen_string_literal: true

require "dicey/cli/options"

module Dicey
  RSpec.describe CLI::Options do
    subject(:options) { described_class.new }

    context "without arguments" do
      let(:argv) { [] }

      it "returns empty arguments, retaining default options" do
        expect(options.read(argv)).to eq []
        expect(options.to_h).to eq CLI::Options::DEFAULT_OPTIONS
      end
    end

    context "with some options and arguments" do
      let(:argv) { %w[-m r 3d1 --format gnuplot 2d2] }

      it "returns arguments, setting options" do
        expect(options.read(argv)).to eq %w[3d1 2d2]
        expect(options[:mode]).to eq "roll"
        expect(options[:format]).to eq "gnuplot"
      end
    end

    context "with -v" do
      let(:argv) { [%w[-v].sample] }

      it "prints version info and exits" do
        expect { options.read(argv) }
          .to output("Dicey #{Dicey::VERSION}\n").to_stdout.and raise_error SystemExit
      end
    end

    context "with -V/--version" do
      let(:argv) { [%w[-V --version --ver].sample] }

      it "prints version info and exits" do
        expect { options.read(argv) }
          .to output("Dicey #{Dicey::VERSION}\n").to_stdout.and raise_error SystemExit
      end
    end

    context "with -h/--help" do
      let(:argv) { [%w[-h --help --hel].sample] }

      it "prints help info and exits" do
        expect { options.read(argv) }
          .to output(/\AUsage: dicey \[options\] <die> \[<die> ...\]\n/).to_stdout
          .and raise_error SystemExit
      end
    end
  end
end
