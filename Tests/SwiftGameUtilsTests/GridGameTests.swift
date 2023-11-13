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
        XCTAssertEqual(state.states.count, 8)

        state.gridHeight = 4
        XCTAssertEqual(state.gridHeight, 4)
        XCTAssertEqual(state.states.count, 4)
        XCTAssertEqual(state.gridCount, 32)

        state.gridWidth = 40
        XCTAssertEqual(state.gridHeight, 4)
        XCTAssertEqual(state.gridWidth, 40)
        XCTAssertEqual(state.states.count, 4)
        XCTAssertEqual(state.states[0].count, 40)
        XCTAssertEqual(state.gridCount, 160)

        state.gridHeight = 0
        XCTAssertEqual(state.gridHeight, 8)
        XCTAssertEqual(state.states.count, 8)

        state.gridWidth = 0
        XCTAssertEqual(state.gridWidth, 8)
        XCTAssertEqual(state.states[0].count, 8)
    }

    func testInitStateDefault() {
        var state = GridGame()
        XCTAssertEqual(state.stateDefault, -1)
        state = GridGame(stateDefault: 5)
        XCTAssertEqual(state.stateDefault, 5)
        state.stateDefault = 3
        XCTAssertEqual(state.stateDefault, 3)
    }

    func testSetState() {
        var game = GridGame()
        game.setState(atIndex: 0, to: 5)
        XCTAssertEqual(game.states[0][0], 5)
        XCTAssertEqual(game.stateAt(x: 0, y: 0), 5)
        XCTAssertEqual(game.stateAt(index: 0), 5)
        XCTAssertEqual(game.stateAt(point: (x: 0, y:0)), 5)

        game.setState(atPoint: (x:1, y:1), to: 3)
        XCTAssertEqual(game.states[1][1], 3)
        XCTAssertEqual(game.stateAt(x: 1, y: 1), 3)
        XCTAssertEqual(game.stateAt(index: 9), 3)
        XCTAssertEqual(game.stateAt(point: (x: 1, y:1)), 3)

        game.setState(atX: 5, andY: 5, to: 2)
        XCTAssertEqual(game.states[5][5], 2)
        XCTAssertEqual(game.stateAt(x: 5, y: 5), 2)
        XCTAssertEqual(game.stateAt(index: 45), 2)
        XCTAssertEqual(game.stateAt(point: (x: 5, y:5)), 2)
    }

    func testRandomState() {
        var game = GridGame()
        game.randomizeStates()
        for i in 0..<game.gridCount {
            XCTAssertTrue(game.stateAt(index: i)! >= 0)
        }
    }

    func testIndexForPoint() {
        let game = GridGame()
        var indexes = Set<Int>()
        for y in 0..<game.gridHeight {
            for x in 0..<game.gridWidth {
                let index = game.indexFor(point: (x: x, y: y))
                XCTAssertFalse(indexes.contains(index))
                indexes.insert(index)
            }
        }
        XCTAssertEqual(indexes.count, game.gridCount)
        XCTAssertEqual(game.indexFor(point: (x:-1, y:-1)), -1)
        XCTAssertEqual(game.indexFor(point: (x:1, y:game.gridHeight)), -1)
        XCTAssertEqual(game.indexFor(point: (x:game.gridWidth, y:1)), -1)
    }

    func testPointForIndex() {
        let game = GridGame()
        for i in 0..<game.gridCount {
            let point = game.pointFor(index: i)
            XCTAssertTrue(game.indexFor(point: point) == i)
            XCTAssertTrue(point.x < game.gridWidth)
            XCTAssertTrue(point.x >= 0)
            XCTAssertTrue(point.y < game.gridHeight)
            XCTAssertTrue(point.y >= 0)
        }
        let point = game.pointFor(index: -1)
        XCTAssertEqual(point.x, -1)
        XCTAssertEqual(point.y, -1)
    }

}
