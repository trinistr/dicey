# frozen_string_literal: true

RSpec.describe Dicey::CLI::VerbosePrinter do
  subject(:verbose_printer) { described_class.new(verbosity, io) }

  let(:verbosity) { 1 }
  let(:io) { $stdout }

  describe "#print" do
    context "when verbosity is 0" do
      let(:verbosity) { 0 }

      it "does not print anything" do
        expect { verbose_printer.print("test") }.not_to output.to_stdout
        expect { verbose_printer.print("test", 2) }.not_to output.to_stdout
      end
    end

    context "when verbosity is 1" do
      it "prints the message with default verbosity" do
        expect { verbose_printer.print("test") }.to output("test\n").to_stdout
      end

      it "doesn't print the message if minimum verbosity is higher" do
        expect { verbose_printer.print("test", 2) }.not_to output.to_stdout
      end
    end

    context "when verbosity is 2" do
      let(:verbosity) { 2 }

      it "prints the message with lower minimum verbosity" do
        expect { verbose_printer.print("test") }.to output("test\n").to_stdout
      end

      it "prints the message with equal minimum verbosity" do
        expect { verbose_printer.print("test", 2) }.to output("test\n").to_stdout
      end
    end

    context "if IO is not $stdout" do
      let(:io) { StringIO.new }

      it "prints to the specified IO" do
        expect { verbose_printer.print("test") }.not_to output.to_stdout
        expect(io.string).to eq("test\n")
      end
    end
  end
end
