# frozen_string_literal: true

RSpec.describe "Formatting results" do
  require "dicey/cli"

  subject(:cli_call) { Dicey::CLI.call(arguments) }

  let(:arguments) { [*mode, *format, *dice] }
  let(:dice) { %w[2 3] }

  context "if running in distribution mode" do
    # `nil` is for default mode.
    let(:mode) do
      [nil, %w[-m distribution], %w[-m dist], %w[--mode distribution], %w[--mo dist]].sample
    end

    context "with list format" do
      # `nil` is for default format.
      let(:format) { [nil, %w[-f list], %w[-f l], %w[--format list], %w[--for li]].sample }

      it "prints expected text" do
        expect { cli_call }.to output(<<~TEXT).to_stdout
          # D2+D3
          2 => 1
          3 => 2
          4 => 2
          5 => 1
        TEXT
        expect(cli_call).to be true
      end
    end

    context "with gnuplot format" do
      # `nil` is for default format.
      let(:format) { [%w[-f gnuplot], %w[-f gnu], %w[--format gnuplot], %w[--fo g]].sample }

      it "prints expected text" do
        expect { cli_call }.to output(<<~TEXT).to_stdout
          # D2+D3
          2 1
          3 2
          4 2
          5 1
        TEXT
        expect(cli_call).to be true
      end
    end

    context "with json format" do
      # `nil` is for default format.
      let(:format) { [%w[-f json], %w[-f j], %w[--format json], %w[--form j]].sample }

      it "prints expected text" do
        expect { cli_call }.to output(<<~TEXT.chomp).to_stdout
          {"description":"D2+D3","results":{"2":1,"3":2,"4":2,"5":1}}
        TEXT
        expect(cli_call).to be true
      end
    end

    context "with yaml format" do
      # `nil` is for default format.
      let(:format) { [%w[-f yaml], %w[-f y], %w[--format yaml], %w[--f ya]].sample }

      it "prints expected text" do
        expect { cli_call }.to output(<<~TEXT).to_stdout
          ---
          description: D2+D3
          results:
            2: 1
            3: 2
            4: 2
            5: 1
        TEXT
        expect(cli_call).to be true
      end
    end
  end

  context "if running roll mode" do
    let(:mode) { [%w[-m roll], %w[-m r], %w[--mode roll], %w[--mo r]].sample }

    let(:roll) do
      seed = rand
      Dicey::AbstractDie.srand(seed)
      value = Dicey::RegularDie.from_list(2, 3).sum(&:roll)
      Dicey::AbstractDie.srand(seed)
      value
    end

    context "with list format" do
      # `nil` is for default format.
      let(:format) { [nil, %w[-f list], %w[-f l], %w[--format list], %w[--for li]].sample }

      it "prints expected text" do
        expect { cli_call }.to output(<<~TEXT).to_stdout
          # D2+D3
          roll => #{roll}
        TEXT
        expect(cli_call).to be true
      end
    end

    context "with gnuplot format" do
      # `nil` is for default format.
      let(:format) { [%w[-f gnuplot], %w[-f gnu], %w[--format gnuplot], %w[--fo g]].sample }

      it "prints expected text" do
        expect { cli_call }.to output(<<~TEXT).to_stdout
          # D2+D3
          roll #{roll}
        TEXT
        expect(cli_call).to be true
      end
    end

    context "with json format" do
      # `nil` is for default format.
      let(:format) { [%w[-f json], %w[-f j], %w[--format json], %w[--form j]].sample }

      it "prints expected text" do
        expect { cli_call }.to output(<<~TEXT.chomp).to_stdout
          {"description":"D2+D3","results":{"roll":#{roll}}}
        TEXT
        expect(cli_call).to be true
      end
    end

    context "with yaml format" do
      # `nil` is for default format.
      let(:format) { [%w[-f yaml], %w[-f y], %w[--format yaml], %w[--f ya]].sample }

      it "prints expected text" do
        expect { cli_call }.to output(<<~TEXT).to_stdout
          ---
          description: D2+D3
          results:
            roll: #{roll}
        TEXT
        expect(cli_call).to be true
      end
    end
  end
end
