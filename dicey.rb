#!/usr/bin/env ruby

# A little program to calculate frequencies of each possible result
# for a throw of a given collection of dice.
# Using dice with exactly equal number of sides is significantly faster.

# Usage: dicey.rb 4 4 4 # calculate frequencies for 3 4-sided dice

# Asbtract die which may have an arbitrary list of sides,
# not even neccessarily numbers (but preferably so).
class AbstractDie
  attr_reader :sides_list, :sides_num, :enum

  # @param sides_list [Enumerable]
  def initialize(sides_list)
    @sides_list = sides_list.to_a.freeze
    @sides_num = @sides_list.size

    sides_enum = @sides_list.to_enum
    @enum = Enumerator.produce do
      sides_enum.next
    rescue StopIteration
      sides_enum.rewind
      retry
    end
  end

  # Get next side of the die, wrapping from last to first.
  def next
    @enum.next
  end
end

# Regular die, which has N sides with numbers from 1 to N.
class RegularDie < AbstractDie
  class << self
    def generate_dice(m, n)
      (1..m).map { new(n) }
    end
  end
  # @param sides [Integer]
  def initialize(sides)
    super((1..sides))
  end
end

class GenericFrequencies
  # Calculate frequencies for a generic collection of dice through complete iteration (slow).
  #
  # @param dice [Enumerable<RegularDie>]
  # @return [Hash{Integer => Integer}] frequencies of each sum
  def call(dice)
    combine_dice(dice).map(&:sum).tally
  end

  private

  # Get an enumerator which goes through all possible permutations of dice sides.
  #
  # @param dice [Enumerable<AbstractDie>]
  # @return [Enumerator<Array>]
  def combine_dice(dice)
    total = dice.map(&:sides_num).reduce(:*)
    Enumerator.new(total) do |yielder|
      values = dice.map(&:next)
      iterations = dice.map(&:sides_num)
      total.times do
        yielder << values
        dice.each_with_index do |die, i|
          value = die.next
          values[i] = value
          iterations[i] -= 1
          break if iterations[i].nonzero?

          iterations[i] = die.sides_num
        end
      end
    end
  end
end

class RegularFrequencies
  # Calculate frequencies for regular dice with equal number of sides (fast).
  #
  # @param dice [Enumerable<RegularDie>]
  # @return [Hash{Integer => Integer}] frequencies of each sum
  def call(dice)
    min = dice.size
    max = dice.size * dice.first.sides_num
    frequencies = build_multinomial_coefficients(dice.size, dice.first.sides_num)
    (min..max).to_a.zip(frequencies).to_h
  end

  private

  # Calculate coefficients for a multinomial of the form
  # <tt>(x^0 + x^1 +...+ x^n)^m</tt>.
  #
  # @param m [Integer] must be positive (number of dice)
  # @param n [Integer] must be positive (number of sides)
  # @param throw_away_garbage [Boolean] whether to discard unused coefficients (debug option)
  # @return [Array[Integer]]
  # @see https://en.wikipedia.org/wiki/Pascal%27s_triangle
  # @see https://en.wikipedia.org/wiki/Trinomial_triangle
  def build_multinomial_coefficients(m, n, throw_away_garbage: true)
    coefficients = [[1]]
    (1..m).each do |row_index|
      row = [1]
      length = row_index * (n - 1) + 1
      middle = (length / 2).floor
      (1..middle).each do |col_index|
        row << ((col_index - n + 1)..col_index).sum { |i| i < 0 ? 0 : coefficients[-1][i] || 0 }
      end
      ((middle + 1)...length).each do |col_index|
        row << row[length - col_index - 1]
      end
      if throw_away_garbage
        coefficients[0] = row
      else
        coefficients << row
      end
    end
    coefficients.last
  end
end

return unless $PROGRAM_NAME == __FILE__

require "tempfile"

if ARGV.size < 1 || ARGV.any? { _1 == "-h" || _1 == "--help" }
  puts "Usage:"
  puts "  #{Process.argv0} <number of sides> [<number of sides> ...]"
  exit
end

# Actually run the calculations!

dice = ARGV.map { RegularDie.new(_1.to_i) }
tally =
  if dice.all? { _1.sides_num == dice.first.sides_num }
    RegularFrequencies.new.call(dice)
  else
    GenericFrequencies.new.call(dice)
  end

sides_list = dice.map(&:sides_num).join(',')
Tempfile.create do |file|
  tally.each_pair { |k, v| file << "#{k} #{v}\n" }
  file.flush
  Process.wait(
    Process.spawn(
      "gnuplot",
      "-e", "set term png medium size 1000 600",
      "-e", %Q{set output "#{sides_list}-sided dice.png"},
      "-e", "set boxwidth 0.9 relative",
      "-e", "set style fill solid 0.5",
      "-e", %Q{plot [][0:] "#{file.path}" using 1:2:xticlabels(1) with boxes title "#{sides_list}-sided dice", '' using 1:2:2 with labels notitle}
    )
  )
end
