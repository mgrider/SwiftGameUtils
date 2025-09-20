# SwiftGameUtils

This is just a swift package containing a collection of classes and structures I've found useful in various projects.

There are some tests you might use as examples, but for now, use at your own risk.

As of this writing, all "grids" are square grids.

## Contents

- `GenericGridGame` - This is the meat and potatoes of this package, basically a generic class meant to hold a multidimensional array of state structures representing a game's "model". (Note that, `GridGame` is a non-generic class that does the same thing, but assumes that your state is an `Int`. Warning that it might eventually be removed in favor of `GenericGridGame<Int>`, which should be functionally identical.)
- `Coordinate` is a struct with `x` and `y` properties that is heavily used throughout the API.
- `Direction` is an enumeration of the 8 grid-spaces around a given coordinate.
- `Chess` and `Tetromino` - These are some structures meant to represent common grid movement or relative relationships between grid coordinates.
- `UIView+GenericGrid.swift` and `UIView+GenericGridInteraction.swift` – These files contain `UIView` subclasses specifically tailored to represent a `GenericGridGame`.

Everything should have at least some doc comments. Hopefully they're useful.

## TODO

- [ ] some examples
- [ ] getting started instructions
- [ ] documentation
- [ ] version 0.1

## Author

This is almost entirely the product of [Martin Grider](https://github.com/mgrider) futzing around.

## Rough History / Log

### fall 2024

- [x] added `UIView` subclasses
    (Feature parity with the original GGM? Not quite, I guess.)
- [x] added `Chess.swift`
- [x] added a [License](LICENSE), Creative Commons

### summer 2024

- [x] added a generic version of `GridGame`
- [x] added `Tetromino.swift`

### fall 2023

This project was created.

### fall 2021

A project called [EasyGameView](https://github.com/mgrider/EasyGameView) took some ideas from GGM and tried to apply them to SwiftUI. There was [an example project for EasyGameView](https://github.com/mgrider/EasyGameViewExample) for this package also.

### summer 2021

[GGMSwift](https://github.com/mgrider/GGMSwift) was created to (naively) port GGM to Swift.

### prior to this timeline

Once upon a time, many of these same concepts existed in an Objective-C package called [GenericGameModel](https://github.com/mgrider/GenericGameModel).
