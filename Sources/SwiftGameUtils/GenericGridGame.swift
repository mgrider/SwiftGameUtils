import Foundation

public protocol GenericGridGameStateProtocol : Hashable, Codable, Equatable { }

/// Model struct for game state data.
public struct GenericGridGame<StateType: GenericGridGameStateProtocol>: Codable, CustomStringConvertible {

    // MARK: convenience properties

    /// Whether or not the game is over.
    public var isOver = false

    /// Whether or not the game is paused.
    public var isPaused = false

    // MARK: Date & time & game duration (TODO)

    /// The start `Date` of the game.
    var gameStartDate: Date

    // MARK: state properties

    /// A default variable for grid states.
    public var stateDefault: StateType

    /// The value representing an empty game state
    /// Note that this cannot be nil. Use `isValidCoordinate()` to check for out-of-bounds coordinates.
    public var stateEmpty: StateType

    /// game states are between `0` and `stateMax`. This is really used for random state generation.
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
        stateEmpty: StateType,
        statesPossibleRandom: [StateType],
        startDate: Date = Date()
    ) {
        self.gridWidth = gridWidth
        self.gridHeight = gridHeight
        self.stateDefault = stateDefault
        self.stateEmpty = stateEmpty
        self.statesPossibleRandom = statesPossibleRandom
        self.gameStartDate = startDate
        setupGrid()
    }

    /// This re-creates the "grid", which is essentially the multidimensional state array. Called on init.
    mutating private func setupGrid() {
        states.removeAll()
        for y in 0..<gridHeight {
            for x in 0..<gridWidth {
                let coordinate = Coordinate(x: x, y: y)
                states[coordinate] = stateDefault
            }
        }
    }

    /// This creates a new grid, copying over old state values when possible.
    mutating private func resizeGrid() {
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
    mutating public func setState(atX x: Int, andY y: Int, to state: StateType) {
        setState(atCoordinate: Coordinate(x: x, y: y), to: state)
    }

    /// set a single state at a given Coordinate
    mutating public func setState(atCoordinate coordinate: Coordinate, to state: StateType) {
        guard coordinate.x >= 0,
              coordinate.x < gridWidth,
              coordinate.y >= 0,
              coordinate.y < gridHeight else {
            return
        }
        states[coordinate] = state
    }

    /// set a single state when only the index is known
    mutating public func setState(atIndex index: Int, to state: StateType) {
        setState(atCoordinate: coordinateFor(index: index), to: state)
    }

    /// set all states to this new value
    mutating public func setAllStates(to state: StateType) {
        for y in 0..<gridHeight {
            for x in 0..<gridWidth {
                states[Coordinate(x: x, y: y)] = state
            }
        }
    }

    // MARK: randomization

    /// get a random state from the initially provided array
    public func randomStateInt() -> StateType {
        return statesPossibleRandom[Int.random(in: 0..<statesPossibleRandom.count)]
    }

    /// completely randomize the grid states with random values
    mutating public func randomizeStates() {
        for y in 0..<gridHeight {
            for x in 0..<gridWidth {
                states[Coordinate(x: x, y: y)] = randomStateInt()
            }
        }
    }

    // MARK: getting state

    /// get the state from a `Coordinate`
    public func stateAt(coordinate: Coordinate) -> StateType {
        guard isValidCoordinate(coordinate),
              let value = states[coordinate] else {
            return stateEmpty
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

    /// get a state in a position one unit away in a given direction
    public func state(inDirection: Direction, fromX x: Int, andY y: Int) -> StateType {
        switch inDirection {
        case .up:
            return stateAt(x: x, y: y-1)
        case .down:
            return stateAt(x: x, y: y+1)
        case .left:
            return stateAt(x: x-1, y: y)
        case .right:
            return stateAt(x: x+1, y: y)
        }
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
        var string = "GenericGridGame(\(type(of: self)))\n"
        for y in 0..<gridHeight {
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


