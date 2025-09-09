# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Next]

**Added**:
- `AbstractDie.from_list` and `AbstractDie.from_count` methods to easily create many dice.
- Ability to specify multiple dice in shorthand notation, like "*2d6*" or "*3d1,0*".

**Removed**:
- `RegularDie.create_dice` in favor of `AbstractDie.from_count`.

**Changed**:
- Decrease required Ruby version to 3.0.0 (from 3.1.0).
- Rewrite `BruteForce` calculator to be an order of magnitude faster. Uses `Enumerator::Product` if available, otherwise a better implementation than before.
- Change how rolling works to make rolls with very large dice significantly faster.
- Optimize numeric (mainly regular) dice initialization.

**Fixed**:
- Allow calling calculators with an empty list, returning an empty hash.
- Fix `DieFoundry` failing on strings with both decimal numbers and brackets.

[Compare v0.13.1...main](https://github.com/trinistr/dicey/compare/v0.13.1...main)

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

[Compare v0.12.1..main](https://github.com/trinistr/dicey/compare/v0.12.1...v0.13.0)

## [v0.12.1] — 2025-06-29

This update documents how to run **Dicey** online in a more reasonable way than before.

**Added**
- Instructions on running **Dicey** using [RunRuby.dev](https://runruby.dev/gist/476679a55c24520782613d9ceb89d9a3).

[Compare v0.12.0...v0.12.1](https://github.com/trinistr/dicey/compare/v0.12.0...v0.12.1)

## [v0.12.0] — 2024-05-05

Rolling update.

**Added**
- `--mode` option to select between `roll` and `frequencies` (default) modes. While ability to roll dice existed in API for a while, it was not exposed through command line.

**Fixed**
- Change private instance of `Random` in `AbstractDie` to a `@@classvar` to share it between all types of dice.
- Make `JSONFormatter` and `YAMLFormatter` stringify results when they aren't numbers or strings already.

[Compare v0.11.0...v0.12.0](https://github.com/trinistr/dicey/compare/v0.11.0...v0.12.0)

## [v0.11.0] — 2024-05-01

This update brought clarity.

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
- Ability to provide side lists surrounded by round brackets (like `(-1,0,1)`). This fixes problems with negative sides being interpreted as options.

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
