# frozen_string_literal: true

require "dicey/cli/blender"

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

    context "with -v/--version" do
      let(:argv) { [%w[-v --version --ver].sample] }

      it "prints version info and exits" do
        expect { blender_call }
          .to output("dicey #{Dicey::VERSION}\n").to_stdout.and raise_error SystemExit
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
