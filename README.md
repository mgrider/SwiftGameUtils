# SwiftGameUtils

This is just a swift package containing a collection of classes I've found useful in various projects.

For now, use at your own risk.

## Contents

- `GenericGameGrid` - This is the meat and potatoes of this package, basically a way to hold a multidimensional array of state objects. (Note that, if you don't need complex state, `GridGame` assumes state is an `Int`. Warning that it might be removed in favor of `GenericGridGame<Int>`, which should be functionally identical.)
- Most other structures in this package (`Coordinate` and `Direction` in particular) only exist to reference/access states in the `GenricGameGrid`.
- `Chess` and `Tetromino` - These are simple structures meant to represent some relative grid movement.
- `UIView+GenericGrid.swift` and `UIView+GenericGridInteraction.swift` – These files contain `UIView` subclasses specifically tailored to represent a `GenericGameGrid`.

## TODO

- [ ] some examples
- [ ] getting started instructions
- [ ] documentation
- [ ] add a License
- [ ] version 0.1

## Author

This is almost entirely the product of [Martin Grider](https://github.com/mgrider) futzing around.

## History

Once upon a time, many of these same concepts existed in an Objective-C package called [GenericGameModel](https://github.com/mgrider/GenericGameModel).

### fall 2024

- [x] added `UIView` subclasses
    (Feature parity with the original GGM? Not quite, I guess.)
- [x] added `Chess.swift`

### summer 2024

- [x] added a generic version of `GridGame`
- [x] added `Tetromino.swift`

### fall 2023

This project was created.

### fall 2021

A project called [EasyGameView](https://github.com/mgrider/EasyGameView) took some ideas from GGM and tried to apply them to SwiftUI. There was [an example project for EasyGameView](https://github.com/mgrider/EasyGameViewExample) for this package also.

### summer 2021

[GGMSwift](https://github.com/mgrider/GGMSwift) was created to (naively) port GGM to Swift.
