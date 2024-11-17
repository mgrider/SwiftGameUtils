import Foundation

public protocol CoordinateProtocol : Hashable, Codable, Equatable { }

public struct Coordinate: CoordinateProtocol {
    public var x: Int = 0
    public var y: Int = 0

    public init(x: Int = 0, y: Int = 0) {
        self.x = x
        self.y = y
    }

    public init(_ x: Int = 0, _ y: Int = 0) {
        self.x = x
        self.y = y
    }

    public init(inDirection direction: Direction) {
        self = direction.offset()
    }

    /// Implementing Hashable protocol
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }

    /// Implementing Equatable protocol
    public static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    public static func +(lhs: Coordinate, rhs: Coordinate) -> Coordinate {
        return Coordinate(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    public static var zero: Coordinate { return Coordinate() }
}
