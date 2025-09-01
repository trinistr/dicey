# Dicey

> [!TIP]
> You may be viewing documentation for an older (or newer) version of the gem than intended. Look at [Changelog](https://github.com/trinistr/dicey/blob/main/CHANGELOG.md) to see all versions, including unreleased changes.

<!-- Latest: [![Gem Version](https://badge.fury.io/rb/dicey.svg?icon=si%3Arubygems)](https://rubygems.org/gems/dicey) -->
<!-- [![CI](https://github.com/trinistr/dicey/actions/workflows/CI.yaml/badge.svg)](https://github.com/trinistr/dicey/actions/workflows/CI.yaml) -->

***

The premier solution in total paradigm shift for resolving dicey problems of tomorrow, today, used by industry-leading professionals around the world!

In seriousness, this program produces total frequency (probability) distributions of all possible dice rolls for a given set of dice. Dice in such a set can be different or even have arbitrary numbers on the sides.

## No installation

Thanks to the efforts of Ruby developers, you can try **Dicey** online!
1. Head over to https://runruby.dev/gist/476679a55c24520782613d9ceb89d9a3
2. Make sure that "*-main.rb*" is open
3. Input arguments between "ARGUMENTS" lines, separated by spaces.
4. Click "**Run code**" button below the editor.

## Installation

For now, the best way is probably to clone this repo to receive future updates:
```sh
git clone https://github.com/trinistr/dicey.git
```

After that, you can just run `dicey` from the `exe` directory (as `exe/dicey`, probably).

Alternatively, you can install **Dicey** as a full gem by running `rake install:local` from its directory.

> [!TIP]
> Versions upto 0.12.1 were packaged as a single executable file. You can still download it from the [release](https://github.com/trinistr/dicey/releases/tag/v0.12.1).

### Requirements

**Dicey** is developed on Ruby 3.2, but should work fine on 3.0 and later versions. There are no dependencies aside from default gems and common usage will not even load them.

## Usage

Following examples assume that `dicey` (or `dicey-to-gnuplot`) is executable and is in `$PATH`. You can also run it with `ruby dicey` instead.

> [!NOTE]
> 💡 Run `dicey --help` to get a list of all possible options.

### Example 1

Let's start with something simple. Imagine that your Bard character has Vicious Mockery cantrip with 2d4 damage, and you would like to know the distribution of possible damage rolls. Run **Dicey** with two 4s as arguments:
```sh
$ dicey 4 4
```

It should output the following:
```sh
# ⚃;⚃
2 => 1
3 => 2
4 => 3
5 => 4
6 => 3
7 => 2
8 => 1
```

First line is a comment telling you that calculation ran for two D4s. Every line after that has the form `roll sum => frequency`, where frequency is the number of different rolls which result in this sum. As can be seen, 5 is the most common result with 4 possible different rolls.

If probability is preferred, there is an option for that:
```sh
$ dicey 4 4 --result probabilities # or -r p for short
# ⚃;⚃
2 => 0.0625
3 => 0.125
4 => 0.1875
5 => 0.25
6 => 0.1875
7 => 0.125
8 => 0.0625
```

This shows that 5 will probably be rolled a quarter of the time.

### Example 2

During your quest to end all ends you find a cool Burning Sword which deals 1d8 slashing damage and 2d4 fire damage on attack. You run **Dicey** with these dice:
```sh
$ dicey 8 4 4
# [8];⚃;⚃
3 => 1
4 => 3
5 => 6
6 => 10
7 => 13
8 => 15
9 => 16
10 => 16
11 => 15
12 => 13
13 => 10
14 => 6
15 => 3
16 => 1
```

Results show that while the total range is 3–16, it is much more likely to roll numbers in the 6–13 range. That's pretty fire, huh?

If you downloaded `dicey-to-gnuplot` and have [gnuplot](http://gnuplot.info) installed, it is possible to turn these results into a graph with a somewhat clunky command:
```sh
$ dicey 8 4 4 --format gnuplot | dicey-to-gnuplot
# --format gnuplot can be abbreviated to -f g
```

This will create a PNG image named `[8];⚃;⚃.png`:
![Graph of damage roll frequencies for Burning Sword]([8];⚃;⚃.png)

> [!NOTE]
> 💡 It is possible to output JSON or YAML with `--format json` and `--format yaml` respectively.

### Example 3

While walking home from work you decide to take a shortcut through a dark alleyway. Suddenly, you notice a die lying on the ground. Looking closer, it turns out to be a D4, but its 3 side was erased from reality. You just have to learn what impact this has on a roll together with a normal D4. Thankfully, you know just the program for the job.

Having ran to a computer as fast as you can, you sic **Dicey** on the problem:
```sh
$ dicey 1,2,4 4
# (1,2,4);⚃
2 => 1
3 => 2
4 => 2
5 => 3
6 => 2
7 => 1
8 => 1
```

Hmm, this looks normal, doesn't it? But wait, why are there two 2s in a row? Turns out that not having one of the sides just causes the roll frequencies to slightly dip in the middle. Good to know.

> [!TIP]
> 💡 A single integer argument N practically is a shorthand for listing every side from 1 to N.

### Example 4

You have a sudden urge to roll dice while only having boring integer dice at home. Where to find *the cool* dice though?

Look no further than **roll** mode introduced in **Dicey** 0.12:
```sh
dicey 0.5,1.5,2.5 4 --mode roll # As always, can be abbreviated to -m r
# (0.5e0,0.15e1,0.25e1);⚃
roll => 0.35e1 # You probably will get a different value here.
```

> [!NOTE]
> 💡 Roll mode is compatible with `--format`, but not `--result`.

## Diving deeper

For a further discussion of calculations, it is important to understand which classes of dice exist.
- **Regular** die — a die with N sides with sequential integers from 1 to N,
  like a classic cubic D6, D20, or even a coin if you assume that it rolls 1 and 2.
  These are dice used for many tabletop games, including role-playing games.
  Most probably, you will only ever need these and not anything beyond.

> [!TIP]
> 💡 If you only need to roll **regular** dice, this section will not contain anything important.

- **Natural** die has sides with only positive integers or 0. For example, (1,2,3,4,5,6), (5,1,6,5), (1,10000), (1,1,1,1,1,1,1,0).
- **Arithmetic** die's sides form an arithmetic sequence. For example, (1,2,3,4,5,6), (1,0,-1), (2.6,2.1,1.6,1.1).
- **Numeric** die is limited by having sides confined to ℝ (or ℂ if you are feeling particularly adventurous).
- **Abstract** die is not limited by anything other than not having partial sides (and how would that work anyway?).

> [!NOTE]
> 💡 If your die starts with a negative number or only has a single natural side, brackets can be employed to force treating it as a sides list, e.g. `dicey '(-1)'` (quotation is required due to shell processing).

Dicey is in principle able to handle any numeric dice and some abstract dice with well-defined summation (tested on complex numbers), though not every possibility is exposed through command-line interface: that is limited to floating-point values.

Currently, three algorithms are implemented, with different possibilities and trade-offs.

> [!NOTE]
> 💡 Complexity is listed for `n` dice with at most `m` sides and has not been rigorously proven.

### Kronecker substitution

An algorithm based on fast polynomial multiplication. This is the default algorithm, used for most reasonable dice.

- Limitations: only **natural** dice are allowed, including **regular** dice.
- Example: `dicey 5 3,4,1 '(0)'`
- Complexity: `O(m⋅n)` where `m` is the highest value

### Multinomial coefficients

This algorithm is based on raising a univariate polynomial to a power and using the coefficients of the result, though certain restrictions are lifted as they don't actually matter for the calculation.

- Limitations: only *equal* **arithmetic** dice are allowed.
- Example: `dicey 1.5,3,4.5,6 1.5,3,4.5,6 1.5,3,4.5,6`
- Complexity: `O(m⋅n²)`

### Brute force

As a last resort, there is a brute force algorithm which goes through every possible dice roll and adds results together. While quickly growing terrible in performace, it has the largest input space, allowing to work with completely nonsensical dice, including aforementioned dice with complex numbers.

- Limitations: objects on dice sides must be numbers.
- Example: `dicey 5 1,0.1,2 1,-1,1,-1,0`
- Complexity: `O(mⁿ)`

## Development

After checking out the repo, run `bundle` (or `bundle install`) to install dependencies. Then, run `rake spec` to run the tests, `rake rubocop` to lint code and check style compliance, `rake rbs` to validate signatures or just `rake` to do everything above. There is also `rake steep` to check typing, and `rake docs` to generate YARD documentation.

You can also run `bin/console` for an interactive prompt that will allow you to experiment, or `bin/benchmark` to run a benchmark script and generate a StackProf flamegraph.

To install this gem onto your local machine, run `rake install`.

To release a new version, run `rake version:{major|minor|patch}`, and then run `rake release`, which will build the package and push the `.gem` file to [rubygems.org](https://rubygems.org). After that, push the release commit and tags to the repository with `git push --follow-tags`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/trinistr/dicey.

### Checklist for a new or updated feature

- Running `rspec` reports 100% coverage (unless it's impossible to achieve in one run).
- Running `rubocop` reports no offenses.
- Running `rake steep` reports no new warnings or errors.
- Tests cover the behavior and its interactions. 100% coverage *is not enough*, as it does not guarantee that all code paths are covered.
- Documentation is up-to-date: generate it with `rake docs` and read it.
- `CHANGELOG.md` lists the change if it has impact on users.
- `README.md` is updated if the feature should be visible there.

## License

This gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT), see [LICENSE.txt](https://github.com/trinistr/dicey/blob/main/LICENSE.txt).
