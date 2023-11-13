import Foundation

/// Model struct for game state data.
public struct GridGame: Codable, CustomStringConvertible {

    // MARK: Sub Types

    /// For relating positions to one another.
    public enum Direction {
        case up
        case down
        case left
        case right
    }

    /// Encapsulation of x,y `Int` values.
    public typealias Point = (x: Int, y: Int)

    // MARK: convenience properties

    /// Whether or not the game is over.
    public var isOver = false

    /// Whether or not the game is paused.
    public var isPaused = false

    // MARK: Date & time & game duration (mostly still TODO)

    /// The start datetime of the game.
    var gameTimeStartDate: Date

    // MARK: state properties

    /// A default variable for grid states.
    public var stateDefault: Int

    /// The value representing an empty game state
    public var stateEmpty = -1

    /// game states are between 0 and gridMaxStateInt
    public var stateMax = 1

    /// A multidimensional array representing the state of each grid space
    private(set) var states = [[Int]]()

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

    // MARK: Initializers & setup

    /// Initializer for the GGM_Model instance.
    public init(gridWidth width: Int = 8,
                gridHeight height: Int = 8,
                stateDefault newStateDefault: Int = -1,
                startDate: Date = Date()) {

        gameTimeStartDate = startDate
        gridWidth = width
        gridHeight = height
        stateDefault = newStateDefault
        setupGrid()
    }

    /// This re-creates the "grid", which is essentially the multidimensional state array. Called on init.
    mutating private func setupGrid() {
        states.removeAll()
        for _ in 0..<gridHeight {
            states.append(Array(repeating: stateDefault, count: gridWidth))
        }
    }

    /// This creates a new grid, copying over old state values when possible.
    mutating private func resizeGrid() {
        let oldStates = states
        setupGrid()
        for y in 0..<oldStates.count {
            for x in 0..<oldStates[y].count {
                if y < gridHeight && x < gridWidth {
                    states[y][x] = oldStates[y][x]
                }
            }
        }
    }

    // MARK: setting state

    /// set a single state when x and y are known
    mutating public func setState(atX x: Int, andY y: Int, to state: Int) {
        guard x >= 0, x < gridWidth, y >= 0, y < gridHeight else {
            return
        }
        states[y][x] = state
    }

    /// set a single state when only the index is known
    mutating public func setState(atIndex index: Int, to state: Int) {
        setState(atPoint: pointFor(index: index), to: state)
    }

    /// set a single state at a given Point
    mutating public func setState(atPoint point: Point, to state: Int) {
        setState(atX: point.x, andY: point.y, to: state)
    }

    /// get a random possible state int between 0 and `stateMax`
    func randomStateInt() -> Int {
        return Int.random(in: 0...stateMax)
    }

    /// completely randomize the grid states with values between `0` and `stateMax`
    mutating public func randomizeStates() {
        for y in 0..<gridHeight {
            for x in 0..<gridWidth {
                states[y][x] = randomStateInt()
            }
        }
    }

    /// set all states to this new value
    mutating public func setAllStates(to state: Int) {
        for y in 0..<gridHeight {
            for x in 0..<gridWidth {
                states[y][x] = state
            }
        }
    }

    // MARK: getting state

    /// get the state from an index
    public func stateAt(index: Int) -> Int? {
        return stateAt(point: pointFor(index: index))
    }

    /// get the state at a given point
    public func stateAt(point: Point) ->Int? {
        return stateAt(x: point.x, y: point.y)
    }

    /// get a single state value
    public func stateAt(x: Int, y: Int) -> Int? {
        guard x >= 0, y >= 0, x < gridWidth, y < gridHeight else {
            return nil
        }
        return states[y][x]
    }

    /// get a state in a position one unit away in a given direction
    public func state(inDirection: Direction, fromX x: Int, andY y: Int) -> Int? {
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

    // MARK: index to point

    /// Get an index from a point
    public func indexFor(point: Point) -> Int {
        guard point.x >= 0, point.x < gridWidth,
              point.y >= 0, point.y < gridHeight else {
            return -1
        }
        return (point.y * gridHeight) + point.x
    }

    /// Get a Point from an index
    public func pointFor(index: Int) -> Point {
        guard index >= 0, index < gridCount else {
            return Point(x: -1, y: -1)
        }
        let y = index / gridHeight
        let x = index % gridHeight
        return Point(x: x, y: y)
    }

    // MARK: util

    /// True if the given index is in an even row. Used for hexagon rendering.
    public func indexIsInEvenRow(index: Int) -> Bool {
        return (index / gridHeight) % 2 == 0
    }

    // MARK: debug

    /// `toString` for debugging
    func toString() -> String {
        var string = "GGM_Game (\(type(of: self))) \n"
        for y in 0..<gridHeight {
            for x in 0..<gridWidth {
                string += "\(String(describing: states[y][x]).padding(toLength: 2, withPad: " ", startingAt: 0)), "
            }
            //            string += "\(String(describing: states[y]) \n"
            string += "\n"
        }
        string += "Game Over: \(isOver), Paused: \(isPaused)"
        return string
    }

    /// This exists to satisfy `CustomStringConvertible`, and allow you to
    /// `print("\(game)")` where game is an instance of `GGM_Game`.
    public var description: String {
        return toString()
    }
}


