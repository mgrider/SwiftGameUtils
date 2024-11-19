import Foundation

public protocol GenericGridGameStateProtocol : Hashable, Codable, Equatable { }

/// Model class for game state data.
public class GenericGridGame<StateType: GenericGridGameStateProtocol>: Codable, CustomStringConvertible {

    // MARK: convenience properties

    /// Whether or not the game is over.
    public var isOver = false {
        willSet {
            if !isOver, newValue {
                timeDurationUpdate()
            }
        }
    }

    /// Whether or not the game is paused.
    public var isPaused = false {
        didSet {
            if isPaused {
                timeDurationUpdate()
            } else {
                timeStartDate = Date(timeInterval: -timeDuration, since: Date())
            }
        }
    }

    // MARK: Dates & times

    /// The game's duration, or `TimeInterval`.
    ///
    /// Note that this value is only updated under the following circumstances:
    /// - when `isOver` or `isPaused` are changed
    /// - when `timeDurationUpdate()` is called
    public var timeDuration: TimeInterval = 0

    /// The start `Date` of the game.
    public private(set) var timeStartDate: Date

    public func timeDurationUpdate() {
        timeDuration = Date().timeIntervalSince(timeStartDate)
    }

    // MARK: state properties

    /// A default variable for grid states.
    public var stateDefault: StateType

    /// The value representing an empty game state
    /// This will be the same as `stateDefault` unless set explicitly.
    public var stateEmpty: StateType

    /// The value representing an invalid game state
    /// See `isValidCoordinate()` to check for out-of-bounds coordinates, but this will also
    /// be returned from the various `stateAt` functions when an OOB coordinate is asked for.
    public var stateInvalid: StateType

    /// random game states will be ones from this array
    public var statesPossibleRandom: [StateType]

    /// A dictionary representing the state of each grid space
    private(set) var states: [Coordinate: StateType] = [:]

    // MARK: grid properties

    /// Total number of grid states.
    public var gridCount: Int {
        gridWidth * gridHeight
    }

    /// Height of the grid in "units".
    public var gridHeight: Int {
        didSet {
            if gridHeight < 1 { gridHeight = 8 }
            resizeGrid()
        }
    }

    /// Width of the grid in "units".
    public var gridWidth: Int {
        didSet {
            if gridWidth < 1 { gridWidth = 8 }
            resizeGrid()
        }
    }

    // MARK: coordinates

    /// computed property for all the coordinates with states
    public var allCoordinates: [Coordinate] {
        let keys: [Coordinate] = states.keys.map { $0 }
        return keys
    }

    // MARK: Initializers & setup

    /// Initializer
    public init(
        gridWidth: Int = 8,
        gridHeight: Int = 8,
        stateDefault: StateType,
        stateEmpty: StateType? = nil,
        stateInvalid: StateType,
        statesPossibleRandom: [StateType]? = nil,
        startDate: Date = Date()
    ) {
        self.gridWidth = gridWidth
        self.gridHeight = gridHeight
        self.stateDefault = stateDefault
        if let stateEmpty {
            self.stateEmpty = stateEmpty
        } else {
            self.stateEmpty = stateDefault
        }
        self.stateInvalid = stateInvalid
        if let statesPossibleRandom {
            self.statesPossibleRandom = statesPossibleRandom
        } else {
            self.statesPossibleRandom = [stateDefault]
        }
        self.timeStartDate = startDate
        setupGrid()
    }

    /// This re-creates the "grid", which is essentially the multidimensional state array. Called on init.
    private func setupGrid() {
        states.removeAll()
        for y in 0..<gridHeight {
            for x in 0..<gridWidth {
                let coordinate = Coordinate(x: x, y: y)
                states[coordinate] = stateDefault
            }
        }
    }

    /// This creates a new grid, copying over old state values when possible.
    private func resizeGrid() {
        let oldStates = states
        setupGrid()
        for coordinate in oldStates.keys {
            if states[coordinate] != nil {
                states[coordinate] = oldStates[coordinate]
            }
        }
    }

    // MARK: checking for valid coordinates

    /// returns whether the given coordinate is within the bounds of our `gridWidth` and `gridHeight`
    public func isValidCoordinate(_ coordinate: Coordinate) -> Bool {
        return coordinate.x >= 0 &&
        coordinate.x < gridWidth &&
        coordinate.y >= 0 &&
        coordinate.y < gridHeight
    }

    // MARK: setting state

    /// set a single state when x and y are known
    public func setState(atX x: Int, andY y: Int, to state: StateType) {
        setState(atCoordinate: Coordinate(x: x, y: y), to: state)
    }

    /// set a single state at a given Coordinate
    public func setState(atCoordinate coordinate: Coordinate, to state: StateType) {
        guard coordinate.x >= 0,
              coordinate.x < gridWidth,
              coordinate.y >= 0,
              coordinate.y < gridHeight else {
            return
        }
        states[coordinate] = state
    }

    /// set a single state when only the index is known
    public func setState(atIndex index: Int, to state: StateType) {
        setState(atCoordinate: coordinateFor(index: index), to: state)
    }

    /// set all states to this new value
    public func setAllStates(to state: StateType) {
        for y in 0..<gridHeight {
            for x in 0..<gridWidth {
                states[Coordinate(x: x, y: y)] = state
            }
        }
    }

    // MARK: randomization

    /// get a random state from the array stored in `statesPossibleRandom`.
    ///
    /// TODO: make this use a predictable randomizer (maybe one that conforms to `RandomNumberGenerator`)
    ///
    public func randomState() -> StateType {
        return statesPossibleRandom[Int.random(in: 0..<statesPossibleRandom.count)]
    }

    /// randomize a single state from the states stored in `statesPossibleRandom`.
    public func randomizeState(at coordinate: Coordinate) {
        states[coordinate] = randomState()
    }

    /// completely randomize the grid states with random values stored in `statesPossibleRandom`.
    public func randomizeStates() {
        for y in 0..<gridHeight {
            for x in 0..<gridWidth {
                states[Coordinate(x: x, y: y)] = randomState()
            }
        }
    }

    // MARK: getting state

    /// get the state from a `Coordinate`
    public func stateAt(coordinate: Coordinate) -> StateType {
        guard isValidCoordinate(coordinate),
              let value = states[coordinate] else {
            return stateInvalid
        }
        return value
    }

    /// get the state from an index
    public func stateAt(index: Int) -> StateType {
        return stateAt(coordinate: coordinateFor(index: index))
    }

    /// get a single state value
    public func stateAt(x: Int, y: Int) -> StateType {
        let coordinate = Coordinate(x: x, y: y)
        return stateAt(coordinate: coordinate)
    }

    /// Get a state in a position one unit away in a given direction.
    ///
    /// Note that this assumes origin (0x0) is upper-left, so a direction of `.down` has a `Coordinate`
    /// value of `y + 1`. (This is how the default, and how the grid is printed in `.toString()`, and
    /// how it's drawn using the `UIKit` subclasses.)
    public func stateInDirection(
        _ direction: Direction,
        from coordinate: Coordinate,
        positiveYIsDown: Bool = true
    ) -> StateType {
        if positiveYIsDown {
            let directionCoordinate = coordinate + Coordinate(inDirection: direction)
            print("dir: \(direction), coord: \(coordinate), dirCoord: \(directionCoordinate)")
            return stateAt(coordinate: directionCoordinate)
        } else {
            let directionCoordinate = coordinate + Coordinate(inDirection: direction).reverseY()
            return stateAt(coordinate: directionCoordinate)
        }
    }

    /// Get a state in a position one unit away in the given direction.
    ///
    /// Note that this assumes origin (0x0) is upper-left, so a direction of `.down` has a `Coordinate`
    /// value of `y + 1`. (This is how the default, and how the grid is printed in `.toString()`, and
    /// how it's drawn using the `UIKit` subclasses.)
    public func state(
        inDirection direction: Direction,
        fromX x: Int,
        andY y: Int,
        positiveYIsDown: Bool = true
    ) -> StateType {
        let coordinate = Coordinate(x: x, y: y)
        return stateInDirection(direction, from: coordinate, positiveYIsDown: positiveYIsDown)
    }

    // MARK: isEmpty

    /// Note that this returns false if the coordinate is out of bounds. Use `isValidCoordinate` for bounds checking.
    public func isEmptyAt(coordinate: Coordinate) -> Bool {
        guard let state = states[coordinate] else { return false }
        return state == stateEmpty
    }

    /// Note that this returns false if the coordinate is out of bounds. Use `isValidCoordinate` for bounds checking.
    public func isEmptyAt(x: Int, y: Int) -> Bool {
        let coordinate = Coordinate(x: x, y: y)
        return isEmptyAt(coordinate: coordinate)
    }

    // MARK: isValid

    /// Note that this returns false if the coordinate is out of bounds. Use `isValidCoordinate` for bounds checking.
    public func isValidAt(coordinate: Coordinate) -> Bool {
        guard let state = states[coordinate] else { return false }
        return state != stateInvalid
    }

    /// Note that this returns false if the coordinate is out of bounds. Use `isValidCoordinate` for bounds checking.
    public func isValidAt(x: Int, y: Int) -> Bool {
        let coordinate = Coordinate(x: x, y: y)
        return isValidAt(coordinate: coordinate)
    }

    // MARK: index point coordinate conversion

    /// Get a `Coordinate` from an index.
    public func coordinateFor(index: Int) -> Coordinate {
        guard index >= 0, index < gridCount else {
            return Coordinate(x: -1, y: -1)
        }
        let y = index / gridHeight
        let x = index % gridHeight
        return Coordinate(x: x, y: y)
    }

    /// Get an index from a point
    public func indexFor(coordinate: Coordinate) -> Int {
        guard coordinate.x >= 0, coordinate.x < gridWidth,
              coordinate.y >= 0, coordinate.y < gridHeight else {
            return -1
        }
        return (coordinate.y * gridHeight) + coordinate.x
    }

    // MARK: util

    /// True if the given index is in an even row. Used for hexagon rendering.
    public func indexIsInEvenRow(index: Int) -> Bool {
        return (index / gridHeight) % 2 == 0
    }

    // MARK: debug

    /// `toString` for debugging
    func toString() -> String {
        var string = "GenericGridGame(\(type(of: self)))\n    "
        for x in 0..<gridWidth {
            string += "\(String(describing: x).padding(toLength: 2, withPad: " ", startingAt: 0)), "
        }
        string += "\n"
        for y in 0..<gridHeight {
            string += "\(String(describing: y).padding(toLength: 2, withPad: " ", startingAt: 0)): "
            for x in 0..<gridWidth {
                let state = stateAt(x: x, y: y)
                string += "\(String(describing: state).padding(toLength: 2, withPad: " ", startingAt: 0)), "
            }
            //            string += "\(String(describing: states[y]) \n"
            string += "\n"
        }
        string += "Game Over: \(isOver), Paused: \(isPaused)"
        return string
    }

    /// This exists to satisfy `CustomStringConvertible`, and allow you to
    /// `print("\(game)")` where game is an instance of `GenericGridGame`.
    public var description: String {
        return toString()
    }
}


