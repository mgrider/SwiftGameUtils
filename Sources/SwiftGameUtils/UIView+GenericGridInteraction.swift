import UIKit

/// Defines a public interface for turning on and off interactions with an instance that
/// conforms to `GenericGameGridUIViewProtocol`. (Most likely a subclass
/// of `UIViewGenericGrid`.)
///
public protocol GenericGameGridUIViewInteractionProtocol: AnyObject {

    /// Turns on drag events for the entire grid. Note that this does nothing unless you have a drag delegate.
    ///
    /// Internally, this uses a `UIPanGestureRecognizer`.
    var dragInteractionEnabled: Bool { get set }

    /// The delegate that will receive `GenericGameGridDragEvent` callbacks.
    var dragDelegate: GenericGameGridDragDelegate? { get set }

    /// Turns on tap delegate callbacks for the grid. Note that this does nothing unless you have set a tap delegate.
    ///
    /// Internally, this uses a `UITapGestureRecognizer`.
    var tapInteractionEnabled: Bool { get set }

    /// The delegate that will receive tap notifications.
    var tapDelegate: GenericGameGridTapDelegate? { get set }
}

/// A drag event that gets passed to the delegate if one is set.
public struct GenericGameGridDragEvent: Equatable {
    public enum State: Equatable {
        case began
        case continued
        case ended
    }
    public let coordinate: Coordinate
    public let coordinateBegan: Coordinate
    public let point: CGPoint
    public let pointBegan: CGPoint
    public let state: State

    /// the orthogonal direction the drag is farthest in from its start position
    public func directionOrthogonalFromStart() -> Direction {
        let verticalOffset = Float(point.y - pointBegan.y)
        let horizontalOffset = Float(point.x - pointBegan.x)
        if fabsf(verticalOffset) > fabsf(horizontalOffset) {
            // moving vertically
            if verticalOffset > 0 {
                return .down
            } else {
                return .up
            }
        } else {
            // moving horizontally
            if horizontalOffset > 0 {
                return .right
            } else {
                return .left
            }
        }
    }
}

/// Defines a delegate responsible for responding to drag (pan) events on your grid view.
///
public protocol GenericGameGridDragDelegate: AnyObject {

    /// Use the event to respond to drag interactions
    func drag(
        event: GenericGameGridDragEvent,
        onGrid grid: some GenericGameGridUIViewProtocol
    )

    /// If this returns true you will get a continuous stream of events while the drag is in progress.
    ///
    /// When it returns false, you should only receive a new drag event callback when the coordinate
    /// point of the drag has changed from the previous drag event coordinate.
    func dragContinuousWanted() -> Bool

}

/// Defines a delegate responsible for responding to tap events on your grid view.
///
public protocol GenericGameGridTapDelegate: AnyObject {

    /// A tap was detected
    func tap(
        atCoordinate coordinate: Coordinate,
        andPoint point: CGPoint,
        onGrid grid: some GenericGameGridUIViewProtocol
    )
}
