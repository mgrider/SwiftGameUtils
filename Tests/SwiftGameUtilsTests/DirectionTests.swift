import XCTest
@testable import SwiftGameUtils

extension Int: GenericGridGameStateProtocol { }

final class DirectionTests: XCTestCase {

    var subject: GenericGridGame<Int>!

    override func setUp() {
        super.setUp()
        subject = GenericGridGame<Int>(
            gridWidth: 8,
            gridHeight: 8,
            stateDefault: 0,
            stateInvalid: -1
        )
        var sequencialState: Int = 0
        for y in 0..<8 {
            for x in 0..<8 {
                subject.setState(atX: x, andY: y, to: sequencialState)
                sequencialState += 1
            }
        }
    }

    func testDown() {
        XCTAssertEqual(subject.state(inDirection: .down, fromX: 0, andY: 0), 8)
        XCTAssertEqual(subject.state(inDirection: .down, fromX: 0, andY: 1), 16)
        XCTAssertEqual(subject.state(inDirection: .down, fromX: 0, andY: 2), 24)
        XCTAssertEqual(subject.state(inDirection: .down, fromX: 0, andY: 3), 32)
        XCTAssertEqual(subject.state(inDirection: .down, fromX: 0, andY: 4), 40)
        XCTAssertEqual(subject.state(inDirection: .down, fromX: 0, andY: 5), 48)
        XCTAssertEqual(subject.state(inDirection: .down, fromX: 7, andY: 6), 63)
        XCTAssertEqual(subject.state(inDirection: .down, fromX: 7, andY: 7), -1)
    }

    func testLeft() {
        print("\(subject.toString())")
        XCTAssertEqual(subject.state(inDirection: .left, fromX: 0, andY: 0), -1)
        XCTAssertEqual(subject.state(inDirection: .left, fromX: 1, andY: 0), 0)
        XCTAssertEqual(subject.state(inDirection: .left, fromX: 2, andY: 0), 1)
        XCTAssertEqual(subject.state(inDirection: .left, fromX: 7, andY: 7), 62)
    }

    func testRight() {
        print("\(subject.toString())")
        XCTAssertEqual(subject.state(inDirection: .right, fromX: 0, andY: 0), 1)
        XCTAssertEqual(subject.state(inDirection: .right, fromX: 1, andY: 0), 2)
        XCTAssertEqual(subject.state(inDirection: .right, fromX: 2, andY: 0), 3)
        XCTAssertEqual(subject.state(inDirection: .right, fromX: 6, andY: 7), 63)
        XCTAssertEqual(subject.state(inDirection: .right, fromX: 7, andY: 7), -1)
    }

    func testUp() {
        XCTAssertEqual(subject.stateAt(x: 0, y: 0), 0)
        XCTAssertEqual(subject.stateAt(x: 0, y: 1), 8)
        XCTAssertEqual(subject.stateAt(x: 0, y: 2), 16)
        XCTAssertEqual(subject.stateAt(x: 0, y: 3), 24)
        XCTAssertEqual(subject.stateAt(x: 0, y: 4), 32)
        XCTAssertEqual(subject.state(inDirection: .up, fromX: 0, andY: 0), -1)
        XCTAssertEqual(subject.state(inDirection: .up, fromX: 0, andY: 1), 0)
        XCTAssertEqual(subject.state(inDirection: .up, fromX: 0, andY: 2), 8)
        XCTAssertEqual(subject.state(inDirection: .up, fromX: 0, andY: 3), 16)
        XCTAssertEqual(subject.state(inDirection: .up, fromX: 0, andY: 4), 24)
        XCTAssertEqual(subject.state(inDirection: .up, fromX: 0, andY: 5), 32)
    }

    func testUpLeft() {
        XCTAssertEqual(subject.stateAt(x: 1, y: 0), 1)
        XCTAssertEqual(subject.stateAt(x: 1, y: 1), 9)
        XCTAssertEqual(subject.stateAt(x: 2, y: 2), 18)
        XCTAssertEqual(subject.stateAt(x: 3, y: 3), 27)
        XCTAssertEqual(subject.stateAt(x: 4, y: 4), 36)
        XCTAssertEqual(subject.state(inDirection: .upLeft, fromX: 1, andY: 1), 0)
        XCTAssertEqual(subject.state(inDirection: .upLeft, fromX: 1, andY: 2), 8)
        XCTAssertEqual(subject.state(inDirection: .upLeft, fromX: 1, andY: 3), 16)
        XCTAssertEqual(subject.state(inDirection: .upLeft, fromX: 1, andY: 4), 24)
        XCTAssertEqual(subject.state(inDirection: .upLeft, fromX: 7, andY: 7), 54)
    }

    func testUpReversed() {
        XCTAssertEqual(subject.state(inDirection: .up, fromX: 0, andY: 0, positiveYIsDown: false), 8)
        XCTAssertEqual(subject.state(inDirection: .up, fromX: 0, andY: 1, positiveYIsDown: false), 16)
        XCTAssertEqual(subject.state(inDirection: .up, fromX: 0, andY: 2, positiveYIsDown: false), 24)
        XCTAssertEqual(subject.state(inDirection: .up, fromX: 0, andY: 3, positiveYIsDown: false), 32)
        XCTAssertEqual(subject.state(inDirection: .up, fromX: 0, andY: 4, positiveYIsDown: false), 40)
    }

    func testUpRight() {
        print("\(subject.toString())")
        XCTAssertEqual(subject.stateAt(x: 1, y: 0), 1)
        XCTAssertEqual(subject.stateAt(x: 1, y: 1), 9)
        XCTAssertEqual(subject.stateAt(x: 2, y: 2), 18)
        XCTAssertEqual(subject.stateAt(x: 3, y: 3), 27)
        XCTAssertEqual(subject.stateAt(x: 6, y: 6), 54)
        XCTAssertEqual(subject.state(inDirection: .upRight, fromX: 0, andY: 1), 1)
        XCTAssertEqual(subject.state(inDirection: .upRight, fromX: 0, andY: 2), 9)
        XCTAssertEqual(subject.state(inDirection: .upRight, fromX: 1, andY: 3), 18)
        XCTAssertEqual(subject.state(inDirection: .upRight, fromX: 2, andY: 4), 27)
        XCTAssertEqual(subject.state(inDirection: .upRight, fromX: 5, andY: 7), 54)
    }
}
