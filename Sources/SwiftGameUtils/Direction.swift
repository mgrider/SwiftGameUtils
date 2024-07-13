import Foundation

/// For relating positions to one another.
public enum Direction: CaseIterable {
    case up
    case down
    case left
    case right

    public func coordinateOffset() -> Coordinate {
        switch self {
        case .up:
            return Coordinate(0,1)
        case .down:
            return Coordinate(0,-1)
        case .left:
            return Coordinate(-1,0)
        case .right:
            return Coordinate(1,0)
        }
    }
}
