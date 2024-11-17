import Foundation

/// For relating positions to one another.
///
/// Note that all coordinate offsets assume positive `y` is `.up`, and positive `x` is `.right`
public enum Direction: CaseIterable {
    case down
    case downLeft
    case downRight
    case left
    case right
    case up
    case upLeft
    case upRight

    /// Returns a `Coordinate` offset in the given `Direction`.
    public func offset() -> Coordinate {
        return Direction.offset(from: self)
    }

    // MARK: static functions

    /// An array of all direction offsets.
    public static let allOffsets: [Coordinate] = Direction.allCases.map { $0.offset() }

    /// An array of all diagonal directions.
    public static let diagonal: [Direction] = [.upLeft, .upRight, .downLeft, .downRight]

    /// An array of all diagonal direction offsets.
    public static let diagonalOffsets: [Coordinate] = Direction.diagonal.map { $0.offset() }

    /// A static function that returns a `Coordinate` offset in the given `Direction`.
    public static func offset(
        from direction: Direction
    ) -> Coordinate {
        switch direction {
        case .down:
            return Coordinate(x: 0, y: -1)
        case .downLeft:
            return Coordinate(x: -1, y: -1)
        case .downRight:
            return Coordinate(x: 1, y: -1)
        case .left:
            return Coordinate(x: -1, y: 0)
        case .right:
            return Coordinate(x: 1, y: 0)
        case .up:
            return Coordinate(x: 0, y: 1)
        case .upLeft:
            return Coordinate(x: -1, y: 1)
        case .upRight:
            return Coordinate(x: 1, y: 1)
        }
    }

    /// An array of all orthogonal directions.
    public static let orthogonal: [Direction] = [.up, .down, .left, .right]

    /// An array of all orthogonal direction offsets.
    public static let orthogonalOffsets: [Coordinate] = Direction.orthogonal.map { $0.offset() }

}
