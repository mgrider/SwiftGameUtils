import Foundation

/// A structure to handle Chess movement and relative positions.
public struct Chess: Hashable, Equatable, Codable {

    /// An enumeration of standard chess colors.
    public enum Color: String, Hashable, Equatable, Codable {
        case black
        case white
    }

    /// An enumeration of standard piece types, plus special types `.empty`, and `.invalid`.
    public enum Piece: String, Hashable, Equatable, Codable {
        case bishop
        case pawn
        case queen
        case king
        case knight
        case rook

        /// This represents an empty space on a chessboard.
        case empty

        /// This represents an invalid `Piece` type, in case that is needed for some reason.
        case invalid

        /// An array of all the valid piece types.
        public static var allValidTypes: [Piece] {
            return [
                .bishop,
                .pawn,
                .queen,
                .king,
                .knight,
                .rook,
            ]
        }

        /// An array of possible capture directions as `Coordinate` offsets.
        ///
        /// Notes:
        /// - For `.pawn`, positive `y` movement is assumed. (Meaning this doesn't consider color.)
        /// - For pieces that can capture more than one space away in a given direction, a single `Coordinate`
        ///   value for each direction is returned. See also `possibleMovementRecurses(forPiece:)`.
        /// - See also `possibleMovementCoordinates(forPiece:)`.
        public static func possibleCaptureCoordinates(
            forPiece piece: Piece
        ) -> [Coordinate] {
            switch piece {
            case .bishop:
                return Direction.diagonalOffsets
            case .pawn:
                return [
                    Coordinate(inDirection: .upLeft),
                    Coordinate(inDirection: .upRight),
                ]
            case .queen:
                return Direction.allOffsets
            case .king:
                return Direction.allOffsets
            case .knight:
                return [
                    Coordinate(x: -1, y: 2),
                    Coordinate(x: -2, y: 1),
                    Coordinate(x: -2, y: -1),
                    Coordinate(x: -1, y: -2),
                    Coordinate(x: 1, y: 2),
                    Coordinate(x: 2, y: 1),
                    Coordinate(x: 2, y: -1),
                    Coordinate(x: 1, y: -2),
                ]
            case .rook:
                return Direction.orthogonalOffsets
            case .empty, .invalid:
                return []
            }
        }

        /// An array of possible movement directions as `Coordinate` offsets.
        ///
        /// Notes:
        /// - For `.pawn`, positive y movement is assumed. (Meaning this doesn't consider color.)
        /// - For pieces that can move more than one space in a given direction, a single `Coordinate`
        ///   value for each direction is returned. See also `possibleMovementRecurses(forPiece:)`.
        /// - See also `possibleCaptureCoordinates(forPiece:)`.
        public static func possibleMovementCoordinates(
            forPiece piece: Piece
        ) -> [Coordinate] {
            switch piece {
            case .bishop:
                return Direction.diagonalOffsets
            case .pawn:
                return [
                    Coordinate(x: 0, y: 1),
                ]
            case .queen:
                return Direction.allOffsets
            case .king:
                return Direction.allOffsets
            case .knight:
                return [
                    Coordinate(x: -1, y: 2),
                    Coordinate(x: -2, y: 1),
                    Coordinate(x: -2, y: -1),
                    Coordinate(x: -1, y: -2),
                    Coordinate(x: 1, y: 2),
                    Coordinate(x: 2, y: 1),
                    Coordinate(x: 2, y: -1),
                    Coordinate(x: 1, y: -2),
                ]
            case .rook:
                return Direction.orthogonalOffsets
            case .empty, .invalid:
                return []
            }
        }

        /// A boolean value indicating whether a given `Piece` type can move (or capture) more than
        /// one space in the `Coordinate` direction indicated by `possibleMovementCoordinates` or
        /// `possibleCaptureCoordinates` respectively.
        public static func possibleMovementRecurses(
            forPiece piece: Piece
        ) -> Bool {
            switch piece {
            case .bishop, .queen, .rook:
                return true
            case .pawn, .king, .knight:
                return false
            case .empty, .invalid:
                return false
            }
        }

        /// A randomly selected valid piece type.
        public static func random() -> Piece {
            let range = 0..<allValidTypes.count
            let index = Int.random(in: range)
            return Chess.Piece.allValidTypes[index]
        }

        /// An array of the whole set, in the proper distributions.
        public static var theWholeSet: [Piece] {
            return [
                .king, .queen, .rook, .rook, .bishop, .bishop, .knight, .knight,
                .pawn, .pawn, .pawn, .pawn, .pawn, .pawn, .pawn, .pawn,
            ]
        }
    }
}
