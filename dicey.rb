#!/usr/bin/env ruby
# frozen_string_literal: true

# A little program to calculate frequencies (tallies) of each possible result
# for a throw of a given collection of dice, drawing result with `gnuplot`.
# Using dice with exactly equal number of sides is significantly faster.

# Usage: dicey.rb 4 4 4 # calculate frequencies for three 4-sided dice
# Usage: dicey.rb 3 6 # calculate frequencies for a pair of 3-sided and 6-sided dice

# Asbtract die which may have an arbitrary list of sides,
# not even neccessarily numbers (but preferably so).
class AbstractDie
  attr_reader :sides_list, :sides_num, :enum

  # @param sides_list [Enumerable]
  def initialize(sides_list)
    @sides_list = sides_list.dup.freeze
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

  def to_s
    "(#{sides_list.join(',')})"
  end
end

# Regular die, which has N sides with numbers from 1 to N.
class RegularDie < AbstractDie
  D6 = '⚀⚁⚂⚃⚄⚅'

  class << self
    # Create a list of regular dice with the same number of sides.
    #
    # @param dice [Integer]
    # @param sides [Integer]
    # @return [Array<RegularDie>]
    def create_dice(dice, sides)
      (1..dice).map { new(sides) }
    end
  end

  # @param sides [Integer]
  def initialize(sides)
    super((1..sides))
  end

  def to_s
    sides_num <= D6.size ? D6[sides_num - 1] : "[#{sides_num}]"
  end
end

# Base frequencies calculator.
class FrequenciesCalculator
  # @param dice [Enumerable<RegularDie>]
  # @return [Hash{Integer => Integer}] frequencies of each sum
  # @raise [RuntimeError] if dice list is invalid for the calculator
  def call(dice)
    raise "#{self.class} can not handle these dice!" unless valid_for?(dice)

    calculate(dice)
  end

  # Whether this calculator can be used for the list of dice.
  #
  # @param dice [Enumerable<RegularDie>]
  # @return [Boolean]
  def valid_for?(dice)
    dice.is_a?(Enumerable) && dice.all? { _1.is_a?(AbstractDie) } && validate(dice)
  end

  private

  # Do additional validation on the dice list.
  # (see #valid_for?)
  def validate(_dice)
    true
  end

  # Peform frequencies calculation.
  # (see #call)
  def calculate(dice)
    raise NotImplementedError
  end
end

# Calculator for a collection of dice using complete iteration (slow).
#
# Able to handle {AbstractDie} lists with numeric sides.
class GenericFrequenciesCalculator < FrequenciesCalculator
  private

  def calculate(dice)
    combine_dice_enumerators(dice).map(&:sum).tally
  end

  # Get an enumerator which goes through all possible permutations of dice sides.
  #
  # @param dice [Enumerable<AbstractDie>]
  # @return [Enumerator<Array>]
  def combine_dice_enumerators(dice)
    sides_num_list = dice.map(&:sides_num)
    total = sides_num_list.reduce(:*)
    Enumerator.new(total) do |yielder|
      current_values = dice.map(&:next)
      remaining_iterations = sides_num_list
      total.times do
        yielder << current_values
        iterate_dice(dice, remaining_iterations, current_values)
      end
    end
  end

  # Iterate through dice, getting next side for first die,
  # then getting next side for second die, resetting first die, and so on.
  # This is analogous to incrementing by 1 in a positional system
  # where each position is a die.
  def iterate_dice(dice, remaining_iterations, current_values)
    dice.each_with_index do |die, i|
      value = die.next
      current_values[i] = value
      remaining_iterations[i] -= 1
      break if remaining_iterations[i].nonzero?

      remaining_iterations[i] = die.sides_num
    end
  end
end

# Calculator for {RegularDie} lists with equal number of sides (fast).
class RegularFrequenciesCalculator < FrequenciesCalculator
  private

  def validate(dice)
    number_of_sides = dice.first.sides_num
    dice.all? { _1.is_a?(RegularDie) && _1.sides_num == number_of_sides }
  end

  def calculate(dice)
    number_of_sides = dice.first.sides_num
    min = dice.size
    max = dice.size * number_of_sides
    frequencies = multinomial_coefficients(dice.size, number_of_sides)
    (min..max).to_a.zip(frequencies).to_h
  end

  # Calculate coefficients for a multinomial of the form
  # <tt>(x^1 +...+ x^m)^n</tt>, where +m+ is the number of sides and +n+ is the number of dice.
  #
  # @param dice [Integer] must be positive
  # @param sides [Integer] must be positive
  # @param throw_away_garbage [Boolean] whether to discard unused coefficients (debug option)
  # @return [Array<Integer>]
  # @see https://en.wikipedia.org/wiki/Pascal%27s_triangle
  # @see https://en.wikipedia.org/wiki/Trinomial_triangle
  def multinomial_coefficients(dice, sides, throw_away_garbage: true)
    # This builds a right triangle where each first element is a 1.
    # Each element is a sum of m elements in the previous row with indices less or equal to its,
    # with out-of-bounds indices corresponding to 0s.
    # Example for m=3:
    # 1
    # 1 1 1
    # 1 2 3 2 1
    # 1 3 6 7 6 3 1, etc.
    coefficients = [[1]]
    (1..dice).each do |row_index|
      row = next_row_of_coefficients(row_index, sides, coefficients.last)
      if throw_away_garbage
        coefficients[0] = row
      else
        coefficients << row
      end
    end
    coefficients.last
  end

  def next_row_of_coefficients(row_index, window_size, previous_row)
    length = row_index * (window_size - 1) + 1
    (0..length).map do |col_index|
      # Have to clamp to 0 to prevent accessing array from the end.
      window_range = ((col_index - (window_size - 1)).clamp(0..)..col_index)
      window_range.sum { |i| previous_row.fetch(i, 0) }
    end
  end
end

return unless $PROGRAM_NAME == __FILE__

require 'tempfile'

if ARGV.empty? || ARGV.any? { ['-h', '--help'].include?(_1) }
  puts 'Usage:'
  puts "  #{Process.argv0} <number of sides> [<number of sides> ...]"
  exit
end

calculators = [RegularFrequenciesCalculator.new, GenericFrequenciesCalculator.new]

if ARGV.include?('--test')
  # These are manually calculated frequencies,
  # with test cases for pretty much all variations of what this program can handle.
  test_data = [
    [[1], { 1 => 1 }],
    [[10], { 1 => 1, 2 => 1, 3 => 1, 4 => 1, 5 => 1, 6 => 1, 7 => 1, 8 => 1, 9 => 1, 10 => 1 }],
    [[2, 2], { 2 => 1, 3 => 2, 4 => 1 }],
    [[3, 3], { 2 => 1, 3 => 2, 4 => 3, 5 => 2, 6 => 1 }],
    [[4, 4], { 2 => 1, 3 => 2, 4 => 3, 5 => 4, 6 => 3, 7 => 2, 8 => 1 }],
    [[2, 2, 2], { 3 => 1, 4 => 3, 5 => 3, 6 => 1 }],
    [[3, 3, 3], { 3 => 1, 4 => 3, 5 => 6, 6 => 7, 7 => 6, 8 => 3, 9 => 1 }],
    [[2, 2, 2, 2], { 4 => 1, 5 => 4, 6 => 6, 7 => 4, 8 => 1 }],
    [[1, 2, 3], { 3 => 1, 4 => 2, 5 => 2, 6 => 1 }],
    [[3, 2, 1], { 3 => 1, 4 => 2, 5 => 2, 6 => 1 }],
    [[4, 6], { 2 => 1, 3 => 2, 4 => 3, 5 => 4, 6 => 4, 7 => 4, 8 => 3, 9 => 2, 10 => 1 }],
    [[[3, 17, 21]], { 3 => 1, 17 => 1, 21 => 1 }],
    [[[3, 3, 3, 3, 3, 5, 5, 5]], { 3 => 5, 5 => 3 }],
    [[[1, 4, 6], [1, 4, 6]], { 2 => 1, 5 => 2, 7 => 2, 8 => 1, 10 => 2, 12 => 1 }],
    [[[3, 4, 3], [1, 3, 2]], { 4 => 2, 5 => 3, 6 => 3, 7 => 1 }]
  ]
  test_data.each do |test|
    dice = test.first.map { _1.is_a?(Integer) ? RegularDie.new(_1) : AbstractDie.new(_1) }
    print "#{dice.join(';')}:\n"
    calculators.each do |calculator|
      print "  #{calculator.class}: "
      if calculator.valid_for?(dice)
        calculator.call(dice) == test.last ? puts('✔') : puts('✘ <- failure!')
      else
        puts '☂'
      end
    end
  end
  return
end

# Actually run the calculations!

dice = ARGV.map { RegularDie.new(_1.to_i) }
frequencies = calculators.find { _1.valid_for?(dice) }.call(dice)

sides_list = dice.map(&:sides_num).join(',')
Tempfile.create do |file|
  frequencies.each_pair { |k, v| file << "#{k} #{v}\n" }
  file.flush
  Process.wait(
    Process.spawn(
      'gnuplot',
      '-e', 'set term png medium size 1000 600',
      '-e', %(set output "#{sides_list}-sided dice.png"),
      '-e', 'set boxwidth 0.9 relative',
      '-e', 'set style fill solid 0.5',
      '-e', %{plot [][0:] "#{file.path}" using 1:2:xticlabels(1) with boxes title "#{sides_list}-sided dice",}\
        " '' using 1:2:2 with labels notitle"
    )
  )
end
