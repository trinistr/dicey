#!/usr/bin/env ruby

require "tempfile"

if ARGV.size < 1 || ARGV.any? { _1 == "-h" || _1 == "--help" }
  puts "Usage:"
  puts "  #{Process.argv0} <number of sides> [<number of sides> ...]"
  exit
end

class Die
  attr_reader :sides, :enum

  def initialize(sides)
    @sides = sides
    @enum = Enumerator.produce(1) { |prev| prev < sides ? prev + 1 : 1 }
  end

  def next
    @enum.next
  end
end

def combine_dice(dice)
  total = dice.map(&:sides).reduce(:*)
  Enumerator.new(total) do |yielder|
    values = dice.map(&:next)
    total.times do
      yielder << values
      dice.each_with_index do |die, i|
        value = die.next
        values[i] = value
        break unless value == 1
      end
    end
  end
end

dice = ARGV.map { Die.new(_1.to_i) }
enum = combine_dice(dice)

tally = enum.map(&:sum).tally
# lowest = tally.keys.reduce { |result, v| v < result ? v : result }
# highest = tally.keys.reduce { |result, v| v > result ? v : result }
# values = tally.sort_by { |k, _v| k }.map { |_k, v| v }

sides_list = dice.map(&:sides).join(',')
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
