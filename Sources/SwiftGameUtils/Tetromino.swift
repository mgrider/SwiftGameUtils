import Foundation

/// A structure to handle Tetromino rotations and positions
public struct Tetromino: Hashable, Equatable, Codable {

    public enum Shape: Int, Hashable, Equatable, Codable {
        case J, L, T, I, Z, S, O, None
        public static var allShapes: [Shape] {
            return [.J, .L, .T, .I, .Z, .S, .O]
        }
        public static func random() -> Shape {
            let range = 0..<6
            let index = Int.random(in: range)
            return Tetromino.Shape.allShapes[index]
        }
    }
    public var shape: Shape

    public enum Rotation: Int, Hashable, Equatable, Codable {
        case r0, r1, r2, r3
        public static func fromCount(_ count: Int) -> Rotation {
            guard let rotation = Rotation(rawValue: count) else {
                return .r0
            }
            return rotation
        }
    }
    public var rotation: Rotation = .r0
    public var rotationCount: Int {
        return rotation.rawValue
    }
    public var rotationNextCount: Int {
        return rotationCount == 3 ? 0 : rotationCount + 1
    }

    public struct Coordinates: Hashable, Equatable, Codable {
        public var a: Coordinate
        public var b: Coordinate
        public var c: Coordinate
        public var d: Coordinate
        init(
            a: Coordinate = .zero,
            b: Coordinate = .zero,
            c: Coordinate = .zero,
            d: Coordinate = .zero
        ) {
            self.a = a
            self.b = b
            self.c = c
            self.d = d
        }
        init(
            _ ax: Int, _ ay: Int,
            _ bx: Int, _ by: Int,
            _ cx: Int, _ cy: Int,
            _ dx: Int, _ dy: Int
        ) {
            self.a = .init(x: ax, y: ay)
            self.b = .init(x: bx, y: by)
            self.c = .init(x: cx, y: cy)
            self.d = .init(x: dx, y: dy)
        }
        public var allCoordinates: [Coordinate] {
            [a, b, c, d]
        }
        public func contains(coord: Coordinate) -> Bool {
            if (a == coord || b == coord || c == coord || d == coord) {
                return true
            } else {
                return false
            }
        }
        public mutating func addToX(_ additive: Int) {
            a.x += additive
            b.x += additive
            c.x += additive
            d.x += additive
        }
        public mutating func addToY(_ additive: Int) {
            a.y += additive
            b.y += additive
            c.y += additive
            d.y += additive
        }
        public func toString() -> String {
            return "Tetromino.Coordinates({\(a.x),\(a.y)}{\(b.x),\(b.y)}{\(c.x),\(c.y)}{\(d.x),\(d.y)})"
        }
        public static var zero: Coordinates { return Coordinates() }
    }
    public var position: Coordinates

    // MARK: init

    init(
        shape: Shape,
        rotation: Rotation = .r0,
        position: Coordinates? = nil
    ) {
        self.shape = shape
        self.rotation = rotation
        if let position {
            self.position = position
        } else {
            self.position = Tetromino.coordinatesForTypeAndRotation(shape, rotation.rawValue)
        }
    }

    /// Use this to initialize a Tetromino whose values are uninitialized. It's type will be `.none`.
    public static func none() -> Tetromino {
        return Tetromino(shape: .None)
    }

    /// Initialize a Tetromino with a random shape.
    public static func random() -> Tetromino {
        return Tetromino(shape: Tetromino.Shape.random())
    }

    // MARK: mutating instance functions

    /// This rotates the Tetromino clockwise
    public mutating func rotate() {
        let newRotationCount = rotationNextCount
        position = Tetromino.rotateCoordinates(
            coordinate: position,
            shape: shape,
            originalRotation: rotationCount,
            newRotation: newRotationCount
        )
        rotation = Rotation.fromCount(newRotationCount)
    }

    // MARK: static coordinates and rotation

    public static func coordinatesForTypeAndRotation(_ s: Shape, _ rotation: Int) ->  Coordinates {
        return Tetromino.coordinatesForTypeAndRotationWhileCentered(s, rotation)
    }

    public static func coordinatesForTypeAndRotationWhileCentered(_ s: Shape, _ rotationCount: Int) -> Coordinates {
        guard let rotation = Rotation(rawValue: rotationCount) else {
            return Coordinates(0, 0, 0, 0, 0, 0, 0, 0)
        }
        // assumption is that rotation is clockwise, 0,0 is upper-left
        switch (s) {
        case .I:
            switch (rotation) {
            case .r0:
                return Coordinates(0, 1, 1, 1, 2, 1, 3, 1)
            case .r1:
                return Coordinates(1, 0, 1, 1, 1, 2, 1, 3)
            case .r2:
                return Coordinates(3, 1, 2, 1, 1, 1, 0, 1)
            case .r3:
                return Coordinates(1, 3, 1, 2, 1, 1, 1, 0)
            }
        case .J:
            switch (rotation) {
            case .r0:
                return Coordinates(0, 1, 1, 1, 2, 1, 0, 0)
            case .r1:
                return Coordinates(0, 0, 0, 1, 0, 2, 1, 0)
            case .r2:
                return Coordinates(2, 0, 1, 0, 0, 0, 2, 1)
            case .r3:
                return Coordinates(1, 2, 1, 1, 1, 0, 0, 2)
            }
        case .L:
            switch (rotation) {
            case .r0:
                return Coordinates(0, 1, 1, 1, 2, 1, 2, 0)
            case .r1:
                return Coordinates(0, 0, 0, 1, 0, 2, 1, 2)
            case .r2:
                return Coordinates(2, 0, 1, 0, 0, 0, 0, 1)
            case .r3:
                return Coordinates(1, 2, 1, 1, 1, 0, 0, 0)
            }
        case .O:
            switch (rotation) {
            case .r0:
                return Coordinates(0, 0, 0, 1, 1, 1, 1, 0)
            case .r1:
                return Coordinates(1, 0, 0, 0, 0, 1, 1, 1)
            case .r2:
                return Coordinates(1, 1, 1, 0, 0, 0, 0, 1)
            case .r3:
                return Coordinates(0, 1, 1, 1, 1, 0, 0, 0)
            }
        case .S:
            switch (rotation) {
            case .r0:
                return Coordinates(0, 1, 1, 1, 1, 0, 2, 0)
            case .r1:
                return Coordinates(1, 0, 1, 1, 2, 1, 2, 2)
            case .r2:
                return Coordinates(2, 1, 1, 1, 1, 2, 0, 2)
            case .r3:
                return Coordinates(1, 2, 1, 1, 0, 1, 0, 0)
            }
        case .Z:
            switch (rotation) {
            case .r0:
                return Coordinates(0, 0, 1, 0, 1, 1, 2, 1)
            case .r1:
                return Coordinates(2, 0, 2, 1, 1, 1, 1, 2)
            case .r2:
                return Coordinates(2, 2, 1, 2, 1, 1, 0, 1)
            case .r3:
                return Coordinates(1, 2, 1, 1, 2, 1, 2, 0)
            }
        case .T:
            switch (rotation) {
            case .r0:
                return Coordinates(2, 1, 1, 1, 0, 1, 1, 0)
            case .r1:
                return Coordinates(1, 2, 1, 1, 1, 0, 2, 1)
            case .r2:
                return Coordinates(0, 1, 1, 1, 2, 1, 1, 2)
            case .r3:
                return Coordinates(1, 0, 1, 1, 1, 2, 0, 1)
            }
        case .None:
            return Coordinates(0, 0, 0, 0, 0, 0, 0, 0)
        }
    }

    public static func coordinatesForTypeAndRotationLeftJustified(
        _ s: Shape,
        _ rotationCount: Int
    ) -> Coordinates {
        guard let rotation = Rotation(rawValue: rotationCount) else {
            return Coordinates(0, 0, 0, 0, 0, 0, 0, 0)
        }
        // assumption is that rotation is clockwise, 0,0 is upper-left
        switch (s) {
        case Shape.I:
            switch (rotation)
            {
            case .r0:
                return Coordinates(0, 0, 1, 0, 2, 0, 3, 0)
            case .r1:
                return Coordinates(0, 0, 0, 1, 0, 2, 0, 3)
            case .r2:
                return Coordinates(3, 0, 2, 0, 1, 0, 0, 0)
            case .r3:
                return Coordinates(0, 3, 0, 2, 0, 1, 0, 0)
            }
        case Shape.J:
            switch (rotation) {
            case .r0:
                return Coordinates(0, 1, 1, 1, 2, 1, 0, 0)
            case .r1:
                return Coordinates(0, 0, 1, 0, 0, 1, 0, 2)
            case .r2:
                return Coordinates(0, 0, 1, 0, 2, 0, 2, 1)
            case .r3:
                return Coordinates(1, 0, 1, 1, 1, 2, 0, 2)
            }
        case Shape.L:
            switch (rotation) {
            case .r0:
                return Coordinates(0, 1, 1, 1, 2, 1, 2, 0)
            case .r1:
                return Coordinates(0, 0, 0, 1, 0, 2, 1, 2)
            case .r2:
                return Coordinates(0, 0, 1, 0, 2, 0, 0, 1)
            case .r3:
                return Coordinates(0, 0, 1, 0, 1, 1, 1, 2)
            }
        case Shape.O:
            return Coordinates(0, 0, 0, 1, 1, 1, 1, 0)
        case Shape.S:
            switch (rotation) {
            case .r0, .r2:
                return Coordinates(0, 1, 1, 1, 1, 0, 2, 0)
            case .r1, .r3:
                return Coordinates(0, 0, 0, 1, 1, 1, 1, 2)
            }
        case Shape.Z:
            switch (rotation) {
            case .r0, .r2:
                return Coordinates(0, 0, 1, 0, 1, 1, 2, 1)
            case .r1, .r3:
                return Coordinates(1, 0, 1, 1, 0, 1, 0, 2)
            }
        case Shape.T:
            switch (rotation) {
            case .r0:
                return Coordinates(0, 0, 1, 0, 2, 0, 1, 1)
            case .r1:
                return Coordinates(1, 0, 1, 1, 1, 2, 0, 1)
            case .r2:
                return Coordinates(1, 0, 1, 1, 2, 1, 0, 1)
            case .r3:
                return Coordinates(0, 0, 0, 1, 0, 2, 1, 1)
            }
        case Shape.None:
            return Coordinates(0, 0, 0, 0, 0, 0, 0, 0)
        }
    }

    public static func rotateCoordinates(
        coordinate: Coordinates,
        shape s: Shape,
        originalRotation: Int,
        newRotation: Int
    ) -> Coordinates {
        let origRot = Tetromino.coordinatesForTypeAndRotation(s, originalRotation)
        let newRot = Tetromino.coordinatesForTypeAndRotation(s, newRotation)
        let subtracted = Tetromino.subtractCoordinates(coordinate, origRot)
        let added = Tetromino.addCoordinates(subtracted, newRot)
//        var DEBUG_ROTATE = false
//        if (DEBUG_ROTATE) {
//            var debugRot = ""
//            debugRot += "rotating:   \(coordinate) + \n"
//            debugRot += "origRot:    \(origRot) + \n"
//            debugRot += "subtracted: \(subtracted) + \n"
//            debugRot += "newRot:     \(newRot) + \n"
//            debugRot += "added:      \(added) + \n"
//            print(debugRot)
//        }
        return added
    }

    public static func addCoordinates(
        _ augend: Coordinates,
        _ addend: Coordinates
    ) -> Coordinates {
        var sum: Coordinates = .init()
        sum.a.x = augend.a.x + addend.a.x
        sum.a.y = augend.a.y + addend.a.y
        sum.b.x = augend.b.x + addend.b.x
        sum.b.y = augend.b.y + addend.b.y
        sum.c.x = augend.c.x + addend.c.x
        sum.c.y = augend.c.y + addend.c.y
        sum.d.x = augend.d.x + addend.d.x
        sum.d.y = augend.d.y + addend.d.y
        return sum
    }

    public static func subtractCoordinates(
        _ minuend: Coordinates,
        _ subtrahend: Coordinates
    ) -> Coordinates {
        var difference = Coordinates()
        difference.a.x = minuend.a.x - subtrahend.a.x
        difference.a.y = minuend.a.y - subtrahend.a.y
        difference.b.x = minuend.b.x - subtrahend.b.x
        difference.b.y = minuend.b.y - subtrahend.b.y
        difference.c.x = minuend.c.x - subtrahend.c.x
        difference.c.y = minuend.c.y - subtrahend.c.y
        difference.d.x = minuend.d.x - subtrahend.d.x
        difference.d.y = minuend.d.y - subtrahend.d.y
        return difference
    }

    public static func columnAndRowCountsForShapeAndRotation(
        _ s: Shape,
        _ rotationCount: Int
    ) -> Coordinate {
        guard let rotation = Rotation(rawValue: rotationCount) else {
            return .zero
        }
        switch (s) {
        case Shape.I:
            switch (rotation) {
            case .r0, .r2:
                return Coordinate(4, 1)
            case .r1, .r3:
                return Coordinate(1, 4)
            }
        case .J, .L, .S, .Z, .T:
            switch (rotation) {
            case .r0, .r2:
                return Coordinate(3,2)
            case .r1, .r3:
                return Coordinate(2,3)
            }
        case Shape.O:
            return Coordinate(2,2)
        case Shape.None:
            return Coordinate.zero
        }
    }

}
