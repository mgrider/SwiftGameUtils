import XCTest
@testable import SwiftGameUtils

final class SwiftGameUtilsTests: XCTestCase {

    func testGridCount() {
        let state = GridGame()
        XCTAssertEqual(state.gridWidth, 8)
        XCTAssertEqual(state.gridHeight, 8)
        XCTAssertEqual(state.gridCount, 64)

        let smallState = GridGame(gridWidth: 4, gridHeight: 3)
        XCTAssertEqual(smallState.gridWidth, 4)
        XCTAssertEqual(smallState.gridHeight, 3)
        XCTAssertEqual(smallState.gridCount, 12)
    }

    func testGridHeightAndWidthResizeGrid() {
        var state = GridGame()
        XCTAssertEqual(state.gridHeight, 8)
        XCTAssertEqual(state.states.count, 64)

        state.gridHeight = 4
        XCTAssertEqual(state.gridHeight, 4)
        XCTAssertEqual(state.states.count, 32)
        XCTAssertEqual(state.gridCount, 32)

        state.gridWidth = 40
        XCTAssertEqual(state.gridHeight, 4)
        XCTAssertEqual(state.gridWidth, 40)
        XCTAssertEqual(state.states.count, 160)
        XCTAssertEqual(state.states.values.count, 160)
        XCTAssertEqual(state.gridCount, 160)

        state.gridHeight = 0
        XCTAssertEqual(state.gridHeight, 8)
        XCTAssertEqual(state.states.count, 320) // 8*40

        state.gridWidth = 0
        XCTAssertEqual(state.gridWidth, 8)
        XCTAssertEqual(state.states.values.count, 64) // 8*8
    }

    func testInitStateDefault() {
        var game = GridGame()
        XCTAssertEqual(game.stateDefault, -1)
        game = GridGame(stateDefault: 5)
        XCTAssertEqual(game.stateDefault, 5)
        game.stateDefault = 3
        XCTAssertEqual(game.stateDefault, 3)
        game.gridHeight = 1
        game.gridWidth = 1
        game.gridHeight = 8
        game.gridWidth = 8
        for i in 1..<game.gridCount {
            // skip the first one, it didn't get reset to default
            XCTAssertEqual(game.stateAt(index: i), 3)
        }
    }

    func testIsOutOfBounds() {
        let game = GridGame()
        XCTAssertTrue(game.isValidCoordinate(Coordinate(x: 0, y: 0)))
        XCTAssertTrue(game.isValidCoordinate(Coordinate(x: 1, y: 0)))
        XCTAssertTrue(game.isValidCoordinate(Coordinate(x: 1, y: 2)))
        XCTAssertTrue(game.isValidCoordinate(Coordinate(x: 1, y: 7)))
        XCTAssertTrue(game.isValidCoordinate(Coordinate(x: 3, y: 5)))
        XCTAssertTrue(game.isValidCoordinate(Coordinate(x: 3, y: 7)))
        XCTAssertTrue(game.isValidCoordinate(Coordinate(x: 7, y: 7)))
        XCTAssertFalse(game.isValidCoordinate(Coordinate(x: 7, y: 8)))
        XCTAssertFalse(game.isValidCoordinate(Coordinate(x: 800, y: 7)))
        XCTAssertFalse(game.isValidCoordinate(Coordinate(x: 0, y: -1)))
        XCTAssertFalse(game.isValidCoordinate(Coordinate(x: -1, y: 1)))
        XCTAssertFalse(game.isValidCoordinate(Coordinate(x: -100, y: 1)))
    }

    func testSetState() {
        var game = GridGame()
        game.setState(atIndex: 0, to: 5)
        XCTAssertEqual(game.stateAt(x: 0, y: 0), 5)
        XCTAssertEqual(game.stateAt(index: 0), 5)

        game.setState(atX: 1, andY: 1, to: 3)
        XCTAssertEqual(game.states[Coordinate(x: 1, y: 1)], 3)
        XCTAssertEqual(game.stateAt(x: 1, y: 1), 3)
        XCTAssertEqual(game.stateAt(index: 9), 3)

        game.setState(atX: 5, andY: 5, to: 2)
        XCTAssertEqual(game.states.values.contains(2), true)
        XCTAssertEqual(game.stateAt(x: 5, y: 5), 2)
        XCTAssertEqual(game.stateAt(index: 45), 2)
    }

    func testRandomState() {
        var game = GridGame(gridWidth: 100, gridHeight: 100)
        game.randomizeStates()
        for i in 0..<game.gridCount {
            XCTAssertTrue(game.stateAt(index: i) >= 0)
            XCTAssertTrue(game.stateAt(index: i) <= game.stateMax)
        }
    }

    func testIndexForCoordinate() {
        let game = GridGame()
        var indexes = Set<Int>()
        for y in 0..<game.gridHeight {
            for x in 0..<game.gridWidth {
                let index = game.indexFor(coordinate: Coordinate(x: x, y: y))
                XCTAssertFalse(indexes.contains(index))
                indexes.insert(index)
            }
        }
        XCTAssertEqual(indexes.count, game.gridCount)
        XCTAssertEqual(game.indexFor(coordinate: Coordinate(x: -1, y: -1)), -1)
        XCTAssertEqual(game.indexFor(coordinate: Coordinate(x:1, y:game.gridHeight)), -1)
        XCTAssertEqual(game.indexFor(coordinate: Coordinate(x:game.gridWidth, y:1)), -1)
    }

    func testCoordinateForIndex() {
        let game = GridGame()
        for i in 0..<game.gridCount {
            let coordinate = game.coordinateFor(index: i)
            XCTAssertTrue(game.indexFor(coordinate: coordinate) == i)
            XCTAssertTrue(coordinate.x < game.gridWidth)
            XCTAssertTrue(coordinate.x >= 0)
            XCTAssertTrue(coordinate.y < game.gridHeight)
            XCTAssertTrue(coordinate.y >= 0)
        }
        let point = game.coordinateFor(index: -1)
        XCTAssertEqual(point.x, -1)
        XCTAssertEqual(point.y, -1)
    }

    func testToString() {
        let game = GridGame()
        let gameString = "\(game)"
        let result = """
GridGame (GridGame) 
-1, -1, -1, -1, -1, -1, -1, -1, 
-1, -1, -1, -1, -1, -1, -1, -1, 
-1, -1, -1, -1, -1, -1, -1, -1, 
-1, -1, -1, -1, -1, -1, -1, -1, 
-1, -1, -1, -1, -1, -1, -1, -1, 
-1, -1, -1, -1, -1, -1, -1, -1, 
-1, -1, -1, -1, -1, -1, -1, -1, 
-1, -1, -1, -1, -1, -1, -1, -1, 
Game Over: false, Paused: false
"""
        XCTAssertEqual(gameString, "\(result)")
    }

}
