# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Next]

**Changed**
- `KroneckerSubstitution` calculator now accepts dice with all integers (including negative). Additionally, performance now depends on the total range of numbers instead of the maximum number.

[Compare v0.16.0...main](https://github.com/trinistr/dicey/compare/v0.16.0...main)

## [v0.16.0] — 2025-10-09

Don't let the small number of changes fool you: this is a massive update, finally integrating **vector_number** gem (originally conceived for this exact purpose) to truly support abstract dice. Now you can use any values on dice, not just numbers, adding first-class support for true coins, symbolic dice or even playing cards.

**Added**
- Support for non-numeric dice sides in API and CLI, including calculating distributions and rolling.

**Changed**
- `DieFoundry` now supports lists of strings (and numbers) as input, producing `AbstractDie` objects.
- If gem **vector_number** is available, `BruteForce` and `Empirical` calculators will use it. This allows to work with *any* values on dice.
- The same for `Roller`: roll whatever you want.
- If an `AbstractDie` is encountered without **vector_number** available, a warning will be printed, and calculation will raise an error. Additionally, calculators' `#valid_for?` will return `false` (and warn).

[Compare v0.15.2...v0.16.0](https://github.com/trinistr/dicey/compare/v0.15.2...v0.16.0)

## [v0.15.2] — 2025-10-08

**Changed**
- Rename `total_range` to `range_length` in `DistributionPropertiesCalculator` to differentiate it from `mid_range` better.
- `DistributionPropertiesCalculator` now also returns `modes` with lists of local modes. This is useful for multi-modal distributions.

[Compare v0.15.1...v0.15.2](https://github.com/trinistr/dicey/compare/v0.15.1...v0.15.2)

## [v0.15.1] — 2025-10-07

**Added**
- `DistributionPropertiesCalculator` for calculating mean, mode, expected value, standard deviation and other properties of discrete distributions (not population samples).

**Changed**
- Use `Rational` instead of `Float` for probabilities, maintaining precision.
- Use `Rational` instead of `BigDecimal` for decimal sides. This removes soft dependency on `bigdecimal` gem which is important for online version.

[Compare v0.15.0...v0.15.1](https://github.com/trinistr/dicey/compare/v0.15.0...v0.15.1)

## [v0.15.0] — 2025-09-22

This update aligns **Dicey**'s behavior with practical use based on [online version](https://dicey.bulancov.tech), with some new features.

**Added**
- Ability to specify dice by integer ranges in `DieFoundry` (like "-2..8").
- `Empirical` calculator. It actually rolls dice to acquire approximate probabilities. Not used by CLI at all.
- Ability to pass calculator-specific options in API. Currently only used by `Empirical` calculator for the number of rolls.

**Changed**
- `DieFoundry` no longer accepts single numbers except for positive integers. If a list is desired, a comma must be used. This prevents suprising behavior and possible mistakes.
- `RegularDie#to_s` now presents the die as "D*n*" instead of the old die characters and "[*n*]".
- `AbstractDie#to_s` now adds a comma after a singular side, making output valid as input to `DieFoundry`.
- `AbstractDie#describe` now joins dice by "+" instead of ";". This makes punctuation clearer and emphasizes addition of random variables.

[Compare v0.14.0...v0.15.0](https://github.com/trinistr/dicey/compare/v0.14.0...v0.15.0)

## [v0.14.0] — 2025-09-11

This is a major update, with following features:
- **Dicey** is now significantly more convenient to use when repeated dice are involved, both with CLI and API.
- Support for all Rubies 3+, JRuby and TruffleRuby.
- Full test coverage, improving confidence in behavior.
- Bugfixes and optimizations.

**Added**:
- Ability to specify multiple dice in shorthand notation, like "*2d6*" or "*3d1,0*", available in `DieFoundry#call` and used in CLI.
- `AbstractDie.from_list` and `AbstractDie.from_count` methods to easily create many dice programmatically.

**Removed**:
- `RegularDie.create_dice` in favor of `AbstractDie.from_count`.

**Changed**:
- Decrease required Ruby version to 3.0.0 (from 3.1.0).
- Rewrite `BruteForce` calculator to be an order of magnitude faster. Uses `Enumerator::Product` if available, otherwise a better implementation than before.
- Change how rolling works to make rolls with very large dice significantly faster.
- Optimize numeric (mainly regular) dice initialization.

**Fixed**:
- Allow calling calculators with an empty list, returning an empty hash. CLI still prohibits this.
- Fix `DieFoundry` failing on strings with both decimal numbers and brackets.

[Compare v0.13.1...v0.14.0](https://github.com/trinistr/dicey/compare/v0.13.1...v0.14.0)

## [v0.13.1] — 2025-09-03

**Dicey** has actually been released on RubyGems now! It can be installed with `gem install dicey`.

[Compare v0.13.0...v0.13.1](https://github.com/trinistr/dicey/compare/v0.13.0...v0.13.1)

## [v0.13.0] — 2025-09-01

This update is me finally packaging **Dicey** in a gem format. There are no changes in functionality otherwise.

**Important**: **Dicey** has *not* been released on RubyGems yet.

**Changed**
- Rename `dicey` to `exe/dicey`.
- Rename `gnuplot-for-dicey` to `exe/dicey-to-gnuplot` (note the changed basename).
- Split all classes into their own files with a proper directory structure.
- Delete partial support for non-numeric dice, which didn't actually work.

[Compare v0.12.1...v0.13.0](https://github.com/trinistr/dicey/compare/v0.12.1...v0.13.0)

## [v0.12.1] — 2025-06-29

This update documents how to run **Dicey** online in a more reasonable way than before.

**Added**
- Instructions on running **Dicey** using [RunRuby.dev](https://runruby.dev/gist/476679a55c24520782613d9ceb89d9a3).

[Compare v0.12.0...v0.12.1](https://github.com/trinistr/dicey/compare/v0.12.0...v0.12.1)

## [v0.12.0] — 2024-05-05

Update to add rolling mode.

**Added**
- `--mode` option to select between `roll` and `frequencies` (default) modes. While ability to roll dice existed in API for a while, it was not exposed through command line.

**Fixed**
- Change private instance of `Random` in `AbstractDie` to a `@@classvar` to share it between all types of dice.
- Make `JSONFormatter` and `YAMLFormatter` stringify results when they aren't numbers or strings already.

[Compare v0.11.0...v0.12.0](https://github.com/trinistr/dicey/compare/v0.11.0...v0.12.0)

## [v0.11.0] — 2024-05-01

This update brought clarity with "*README.md*".

**Added**
- "*README.md*", finally.
- `NumericDie` class to separate truly abstract dice from those we can use.

**Changed**
- [BREAKING] Rename "*dicey.rb*" to "*dicey*".
- Rename `CompleteIteration` calculator to `BruteForce`.

[Compare v0.10.1...v0.11.0](https://github.com/trinistr/dicey/compare/v0.10.1...v0.11.0)

## [v0.10.1] — 2024-05-01

This is mostly a bug fix update.

**Added**
- Ability to provide side lists surrounded by round brackets (like `(-1,0,1)`). This allows to mix dice starting with negative numbers and options.

**Fixed**
- Fix `FrozenError` on Ruby 2.7.
- Gracefully handle inability to sort results when it doesn't work.
- Call `#to_a` on sides list before checking if it's empty.

[Compare v0.10.0...v0.10.1](https://github.com/trinistr/dicey/compare/v0.10.0...v0.10.1)

## [v0.10.0] — 2024-04-29

This update improves behavior of dice and broadens the scope of **Multinomial Coefficients** algorithm.

**Added**
- `AbstractDie.rand` and `AbstractDie.srand` for reproducible randomness.
- `AbstractDie#current` to see current value of a die.
- `AbstractDie#==` for comparisons.

**Changed**
- Update `MultinomialCoefficients` to accept arbitrary arithmetic sequences.
- Consistently raise `DiceyError` instead of `RuntimeError` everywhere.

**Fixed**
- Use `BigDecimal` instead of `Float` for non-integer dice created through `DieFoundry` to ensure exact results.

[Compare v0.9.0...v0.10.0](https://github.com/trinistr/dicey/compare/v0.9.0...v0.10.0)

## [v0.9.0] — 2024-04-25

This update significantly speeds up calculations for most useful dice.

**Added**
- `KroneckerSubstitution` calculator for fast calculation when only regular dice or non-regular positive integer dice are involved.

**Changed**
- Rename `RegularFrequenciesCalculator` to `MultinomialCoefficients`.
- Rename `GenericFrequenciesCalculator` to `CompleteIteration`.
- Rename `DiceError` to `DiceyError`.
- Calculators now verify baseline believability of results, possibly raising `DiceyError`.

[Compare v0.8.0...v0.9.0](https://github.com/trinistr/dicey/compare/v0.8.0...v0.9.0)

## [v0.8.0] — 2024-04-25

This update finally allows to use arbitrary numeric dice (with real numbers) on command line.

**Added**
- `DieFoundry` class for easy creation of dice from strings.

**Changed**
- Use `Dicey::DiceError` instead of `RuntimeError` for invalid dice.
- Allow creating non-regular dice from command line using lists of sides.
- Allow non-integer and non-positive sides.

**Fixed**
- Sort results to ensure consistent, readable output with non-regular dice.

[Compare v0.7.0...v0.8.0](https://github.com/trinistr/dicey/compare/v0.7.0...v0.8.0)

## [v0.7.0] — 2024-04-23

This update brings ability to show probabilities instead of frequencies.

**Added**
- `--result` option to select probabilities instead of frequencies.
- `Dicey::VERSION` constant.

[Compare v0.6.1...v0.7.0](https://github.com/trinistr/dicey/compare/v0.6.1...v0.7.0)

## [v0.6.1] — 2024-04-22

**Fixed**
- Fix `AbstractDie#roll` not actually rolling due to using keyword `next`.

[Compare v0.6.0...v0.6.1](https://github.com/trinistr/dicey/compare/v0.6.0...v0.6.1)

## [v0.6.0] — 2024-04-22

**Changed**
- [BREAKING] Move all classes in "*dicey.rb*" into `Dicey` module. Calculators are moved into `Dicey::SumFrequencyCalculators` module. Formatters are moved into `Dicey::OutputFormatters` module.

[Compare v0.5.0...v0.6.0](https://github.com/trinistr/dicey/compare/v0.5.0...v0.6.0)

## [v0.5.0] — 2024-04-22

First tagged version.

**Added**
- "*gnuplot-for-dicey.rb*" script for easy creation of images.

[Compare v0.0.0...v0.5.0](https://github.com/trinistr/dicey/compare/v0.0.0...v0.5.0)

## Before v0.5.0

**Added**
- "*dicey.rb*" script, containing all logic.
- `AbstractDie` and `RegularDie` classes for dice.
- `GenericFrequenciesCalculator` (brute force algorithm) and `RegularFrequenciesCalculator` (multinomial coefficients algorithm) calculators for frequencies.
- `ListFormatter`, `GnuplotFormatter`, `JSONFormatter`, and `YAMLFormatter` formatters for output.
- `--format` and `--test` options.

[Next]: https://github.com/trinistr/dicey/tree/main
[v0.16.0]: https://github.com/trinistr/dicey/tree/v0.16.0
[v0.15.2]: https://github.com/trinistr/dicey/tree/v0.15.2
[v0.15.1]: https://github.com/trinistr/dicey/tree/v0.15.1
[v0.15.0]: https://github.com/trinistr/dicey/tree/v0.15.0
[v0.14.0]: https://github.com/trinistr/dicey/tree/v0.14.0
[v0.13.1]: https://github.com/trinistr/dicey/tree/v0.13.1
[v0.13.0]: https://github.com/trinistr/dicey/tree/v0.13.0
[v0.12.1]: https://github.com/trinistr/dicey/tree/v0.12.1
[v0.12.0]: https://github.com/trinistr/dicey/tree/v0.12.0
[v0.11.0]: https://github.com/trinistr/dicey/tree/v0.11.0
[v0.10.1]: https://github.com/trinistr/dicey/tree/v0.10.1
[v0.10.0]: https://github.com/trinistr/dicey/tree/v0.10.0
[v0.9.0]: https://github.com/trinistr/dicey/tree/v0.9.0
[v0.8.0]: https://github.com/trinistr/dicey/tree/v0.8.0
[v0.7.0]: https://github.com/trinistr/dicey/tree/v0.7.0
[v0.6.1]: https://github.com/trinistr/dicey/tree/v0.6.1
[v0.6.0]: https://github.com/trinistr/dicey/tree/v0.6.0
[v0.5.0]: https://github.com/trinistr/dicey/tree/v0.5.0
