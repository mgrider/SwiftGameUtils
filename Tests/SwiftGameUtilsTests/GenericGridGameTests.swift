import XCTest
@testable import SwiftGameUtils

final class GenericGridGameTests: XCTestCase {

    enum GridState: Int, GenericGridGameStateProtocol {
        case empty = 0
        case first = 1
        case second = 2
        case third = 3
        case none = 4
    }

    var subject: GenericGridGame<GridState>!

    override func setUp() {
        super.setUp()
        subject = GenericGridGame<GridState>(
            stateDefault: .first,
            stateInvalid: .empty,
            statesPossibleRandom: [.second, .third]
        )
    }

    func testGridCount() {
        XCTAssertEqual(subject.gridWidth, 8)
        XCTAssertEqual(subject.gridHeight, 8)
        XCTAssertEqual(subject.gridCount, 64)
    }

    func testAllCoordinates() {
        let allCoordinates = subject.allCoordinates
        XCTAssertEqual(subject.states.count, allCoordinates.count)
        for coordinate in allCoordinates {
            XCTAssertEqual(subject.states[coordinate], subject.stateAt(coordinate: coordinate))
        }
    }

    func testGridHeightAndWidthResizeGrid() {
        XCTAssertEqual(subject.gridHeight, 8)
        XCTAssertEqual(subject.states.count, 64)

        subject.gridHeight = 4
        XCTAssertEqual(subject.gridHeight, 4)
        XCTAssertEqual(subject.states.count, 32)
        XCTAssertEqual(subject.gridCount, 32)

        subject.gridWidth = 40
        XCTAssertEqual(subject.gridHeight, 4)
        XCTAssertEqual(subject.gridWidth, 40)
        XCTAssertEqual(subject.states.count, 160)
        XCTAssertEqual(subject.states.values.count, 160)
        XCTAssertEqual(subject.gridCount, 160)

        subject.gridHeight = 0
        XCTAssertEqual(subject.gridHeight, 8)
        XCTAssertEqual(subject.states.count, 320) // 8*40

        subject.gridWidth = 0
        XCTAssertEqual(subject.gridWidth, 8)
        XCTAssertEqual(subject.states.values.count, 64) // 8*8
    }

    func testInitStateDefault() {
        XCTAssertEqual(subject.stateDefault, .first)
        subject.stateDefault = .none
        XCTAssertEqual(subject.stateDefault, .none)
        subject.gridHeight = 1
        subject.gridWidth = 1
        subject.gridHeight = 8
        subject.gridWidth = 8
        for i in 1..<subject.gridCount {
            // skip the first one, it didn't get reset to default
            XCTAssertEqual(subject.stateAt(index: i), .none)
        }
    }

    func testIsOutOfBounds() {
        XCTAssertTrue(subject.isValidCoordinate(Coordinate(x: 0, y: 0)))
        XCTAssertTrue(subject.isValidCoordinate(Coordinate(x: 1, y: 0)))
        XCTAssertTrue(subject.isValidCoordinate(Coordinate(x: 1, y: 2)))
        XCTAssertTrue(subject.isValidCoordinate(Coordinate(x: 1, y: 7)))
        XCTAssertTrue(subject.isValidCoordinate(Coordinate(x: 3, y: 5)))
        XCTAssertTrue(subject.isValidCoordinate(Coordinate(x: 3, y: 7)))
        XCTAssertTrue(subject.isValidCoordinate(Coordinate(x: 7, y: 7)))
        XCTAssertFalse(subject.isValidCoordinate(Coordinate(x: 7, y: 8)))
        XCTAssertFalse(subject.isValidCoordinate(Coordinate(x: 800, y: 7)))
        XCTAssertFalse(subject.isValidCoordinate(Coordinate(x: 0, y: -1)))
        XCTAssertFalse(subject.isValidCoordinate(Coordinate(x: -1, y: 1)))
        XCTAssertFalse(subject.isValidCoordinate(Coordinate(x: -100, y: 1)))
    }

    func testSetState() {
        subject.setState(atIndex: 0, to: .second)
        XCTAssertEqual(subject.stateAt(x: 0, y: 0), .second)
        XCTAssertEqual(subject.stateAt(index: 0), .second)

        subject.setState(atX: 1, andY: 1, to: .third)
        XCTAssertEqual(subject.states[Coordinate(x: 1, y: 1)], .third)
        XCTAssertEqual(subject.stateAt(x: 1, y: 1), .third)
        XCTAssertEqual(subject.stateAt(index: 9), .third)

        subject.setState(atX: 5, andY: 5, to: .none)
        XCTAssertEqual(subject.states.values.contains(.none), true)
        XCTAssertEqual(subject.stateAt(x: 5, y: 5), .none)
        XCTAssertEqual(subject.stateAt(index: 45), .none)
    }

    func testRandomState() {
        subject.randomizeStates()
        for i in 0..<subject.gridCount {
            XCTAssertTrue(subject.stateAt(index: i) != .none)
            XCTAssertTrue(subject.stateAt(index: i) != .empty)
            XCTAssertTrue(subject.stateAt(index: i) != .first)
        }
        XCTAssertTrue(subject.states.values.contains(.second))
        XCTAssertTrue(subject.states.values.contains(.third))
    }

    func testIndexForCoordinate() {
        var indexes = Set<Int>()
        for y in 0..<subject.gridHeight {
            for x in 0..<subject.gridWidth {
                let index = subject.indexFor(coordinate: Coordinate(x: x, y: y))
                XCTAssertFalse(indexes.contains(index))
                indexes.insert(index)
            }
        }
        XCTAssertEqual(indexes.count, subject.gridCount)
        XCTAssertEqual(subject.indexFor(coordinate: Coordinate(x: -1, y: -1)), -1)
        XCTAssertEqual(subject.indexFor(coordinate: Coordinate(x:1, y:subject.gridHeight)), -1)
        XCTAssertEqual(subject.indexFor(coordinate: Coordinate(x:subject.gridWidth, y:1)), -1)
    }

    func testCoordinateForIndex() {
        for i in 0..<subject.gridCount {
            let coordinate = subject.coordinateFor(index: i)
            XCTAssertTrue(subject.indexFor(coordinate: coordinate) == i)
            XCTAssertTrue(coordinate.x < subject.gridWidth)
            XCTAssertTrue(coordinate.x >= 0)
            XCTAssertTrue(coordinate.y < subject.gridHeight)
            XCTAssertTrue(coordinate.y >= 0)
        }
        let point = subject.coordinateFor(index: -1)
        XCTAssertEqual(point.x, -1)
        XCTAssertEqual(point.y, -1)
    }

    func testToString() {
        guard let subject else {
            XCTFail()
            return
        }
        subject.setAllStates(to: .empty)
        subject.setState(atIndex: 9, to: .first)
        subject.setState(atCoordinate: .init(x: 3, y: 3), to: .second)
        subject.setState(atCoordinate: .init(x: 5, y: 5), to: .third)
        let gameString = "\(subject)"
        let result = """
GenericGridGame(GenericGridGame<GridState>)
    0 , 1 , 2 , 3 , 4 , 5 , 6 , 7 , 
0 : em, em, em, em, em, em, em, em, 
1 : em, fi, em, em, em, em, em, em, 
2 : em, em, em, em, em, em, em, em, 
3 : em, em, em, se, em, em, em, em, 
4 : em, em, em, em, em, em, em, em, 
5 : em, em, em, em, em, th, em, em, 
6 : em, em, em, em, em, em, em, em, 
7 : em, em, em, em, em, em, em, em, 
Game Over: false, Paused: false
"""
        XCTAssertEqual(gameString, "\(result)")
    }

}
