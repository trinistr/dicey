# frozen_string_literal: true

require "dicey/cli"

module Dicey
  RSpec.describe CLI::Blender do
    subject(:blender_call) { described_class.new.call(argv) }

    context "without arguments" do
      let(:argv) { [] }

      it "raises DiceyError" do
        expect { blender_call }.to raise_error Dicey::DiceyError
      end
    end

    context "with some options and arguments" do
      let(:argv) { %w[-m r 3d1 --format gnuplot 2d2] }

      it "produces expected results" do
        expect { blender_call }.to output(/\A# D1\+D1\+D1\+D2\+D2\nroll [5-7]\n\z/).to_stdout
        expect(blender_call).to be true
      end
    end

    context "with -V/--version" do
      let(:argv) { [%w[-V --version --vers].sample] }

      it "prints version info and exits" do
        expect { blender_call }
          .to output("Dicey #{Dicey::VERSION}\n").to_stdout.and raise_error SystemExit
      end
    end

    context "with -v/--verbose" do
      let(:argv) { [%w[-v --verbose --verb].sample, "2d2"] }

      it "prints version info and extra output" do
        expect { blender_call }
          .to output(<<~TEXT).to_stdout
            Dicey #{Dicey::VERSION}
            Selected mode: distribution
            Using calculator: Dicey::DistributionCalculators::Trivial
            # D2+D2
            2 => 1
            3 => 2
            4 => 1
          TEXT
      end
    end

    context "with -h/--help" do
      let(:argv) { [%w[-h --help --hel].sample] }

      it "prints help info and exits" do
        expect { blender_call }
          .to output(/\AUsage: dicey \[options\] <die> \[<die> ...\]\n/).to_stdout
          .and raise_error SystemExit
      end
    end
  end
end
