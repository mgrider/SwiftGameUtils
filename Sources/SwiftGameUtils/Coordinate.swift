import Foundation

public struct Coordinate: Equatable, Codable {
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

    public static var zero: Coordinate { return Coordinate() }
}
