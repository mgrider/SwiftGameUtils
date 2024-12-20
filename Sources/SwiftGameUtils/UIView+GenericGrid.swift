import UIKit

/// The type of grid that is formed by our subviews. Put another way,
/// this defines the pixel relationship between the subviews.
public enum GenericGridStateLayoutType {

    /// A fixed size. Each subview in the grid will be the associated `CGSize` value.
    case fixed(CGSize)

    /// A grid with rectangular subviews whose size is based on the total size of the grid divided by
    /// the game's height and width.
    case rectangle

    /// A grid with square subviews with width & height equal to the smaller dimension, based on
    /// the total view size divided by the game's height and width.
    case square
}

/// This protocol defines a public interface for a `UIView` subclass that can
/// customize its appearance based on an `associatedtype StateType`.
///
/// Typically you would define this `UIView` in your application, so you can specify
/// how it responds to state changes.
///
public protocol GenericGridStateUIViewProtocol: UIView {

    /// This is the generic type that will define your "state".
    associatedtype StateType: GenericGridGameStateProtocol

    init(
        withState state: StateType,
        andCoordinate coordinate: Coordinate,
        inGrid grid: GenericGridGame<StateType>
    )

    /// This function has the responsibility to represent the state to the user.
    func updateView(
        withState state: StateType,
        atCoordinate coordinate: Coordinate,
        inGrid grid: GenericGridGame<StateType>
    )

    /// This function gets called whenever the grid needs to reposition the `UIView`. The grid
    /// never sets the position directly, but instead calls this function. The simplest implementation would
    /// be to set the view's `frame` property to the `position` argument.
    func updateView(
        withPosition position: CGRect,
        atCoordinate coordinate: Coordinate,
        inGrid grid: GenericGridGame<StateType>
    )
}

/// Defines a public interface for the view that holds a grid of subviews, managing
/// their position, as well as interactions.
///
/// For now, this view should be a subclass of `UIViewGenericGrid`.
public protocol GenericGameGridUIViewProtocol: UIView {

    /// This is the generic type that will define your "state".
    associatedtype StateType: GenericGridGameStateProtocol

    /// This was most likely passed in
    var genericGridGame: GenericGridGame<StateType> { get set }

    /// Refreshes ALL subviews to match their corresponding `StateType` values, as well as
    /// sets their frames based on the `GenericGridStateLayoutType`.
    func refreshViewPositionsAndStates()

    /// Refreshes the frame (pixel/point position) of the coordinate subview.
    func refreshViewPosition(at coordinate: Coordinate)

    /// Refreshes the state of the subview corresponding to `Coordinate`. More specifically,
    /// this calls `setupView(forState:atCoordinate:)` on the `UIView` that conforms to
    /// `GenericGridStateUIViewProtocol`.
    func refreshViewState(at coordinate: Coordinate)
}

/// A `UIView` subclass, meant to be extended for your application, that holds a grid of subviews
/// that each correspond to a `Coordinate` in a `GenericGridGame`.
///
/// Each of the subviews should conform to `GenericGridStateUIViewProtocol`, and thus
/// know how to draw itself according to its state and coordinate details.
open class UIViewGenericGrid<ViewType: GenericGridStateUIViewProtocol>:
    UIView,
    GenericGameGridUIViewProtocol,
    GenericGameGridUIViewInteractionProtocol
{

    // MARK: properties

    /// more accurately the "point" height of each subview
    public private(set) var gridPixelHeight: CGFloat = 0

    /// more accurately the "point" width of each subview
    public private(set) var gridPixelWidth: CGFloat = 0

    /// How the grid elements will look – For now this must be passed-in on initialization.
    public private(set) var gridType: GenericGridStateLayoutType = .square

    /// A dictionary of the subviews in this grid, keyed on their `Coordinate` values.
    public private(set) var gridViews: [Coordinate: ViewType] = [:]

    // MARK: init

    public init(
        genericGridGame: GenericGridGame<ViewType.StateType>,
        gridType: GenericGridStateLayoutType = .square,
        rect: CGRect = .zero
    ) {
        self.genericGridGame = genericGridGame
        self.gridType = gridType
        super.init(frame: rect)

        setupInitialGridViewArray()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIView layout

    override public func layoutSubviews() {
        super.layoutSubviews()
        setupPixelSizes()
        refreshViewPositionsAndStates()
    }

    // MARK: GenericGameGridUIViewProtocol

    public var genericGridGame: GenericGridGame<ViewType.StateType> {
        didSet {
            setupPixelSizes()
            setupInitialGridViewArray()
        }
    }

    public func refreshViewPositionsAndStates() {
        for coordinate in genericGridGame.allCoordinates {
            refreshViewPosition(at: coordinate)
            refreshViewState(at: coordinate)
        }
    }

    public func refreshViewPosition(at coordinate: Coordinate) {
        guard let view = gridViews[coordinate] else { return }
        switch gridType {
        case .fixed, .rectangle, .square:
            let point = pointForCoordinate(coordinate)
            let size = CGSize(width: gridPixelWidth, height: gridPixelHeight)
            let position = CGRect(origin: point, size: size)
            view.updateView(withPosition: position, atCoordinate: coordinate, inGrid: genericGridGame)
        }
    }

    public func refreshViewState(at coordinate: Coordinate) {
        guard let view = gridViews[coordinate] else { return }
        let state = genericGridGame.stateAt(coordinate: coordinate)
        view.updateView(withState: state, atCoordinate: coordinate, inGrid: genericGridGame)
    }

    // MARK: GenericGameGridUIViewInteractionProtocol

    public var dragInteractionEnabled: Bool = false {
        didSet {
            if dragInteractionEnabled {
                if dragRecognizer == nil {
                    let gesture = UIPanGestureRecognizer(target: self, action: #selector(dragInteraction))
                    addGestureRecognizer(gesture)
                    dragRecognizer = gesture
                }
            } else {
                if let dragRecognizer {
                    removeGestureRecognizer(dragRecognizer)
                    self.dragRecognizer = nil
                }
            }
        }
    }

    public var dragDelegate: GenericGameGridDragDelegate?

    public var tapInteractionEnabled: Bool = false {
        didSet {
            if tapInteractionEnabled {
                if tapRecognizer == nil {
                    let gesture = UITapGestureRecognizer(target: self, action: #selector(tapInteraction))
                    addGestureRecognizer(gesture)
                    tapRecognizer = gesture
                }
            } else {
                if let tapRecognizer {
                    removeGestureRecognizer(tapRecognizer)
                    self.tapRecognizer = nil
                }
            }
        }
    }

    public var tapDelegate: GenericGameGridTapDelegate?

    // MARK: private interaction stuff

    @objc private func dragInteraction(sender: UIPanGestureRecognizer) {
        guard let dragDelegate else { return }
        let dragPoint = sender.location(in: self)
        guard let dragCoordinate = coordinateForPoint(dragPoint) else {
            return
        }
        switch sender.state {
        case .began:
            dragCoordinateBegan = dragCoordinate
            dragPointBegan = dragPoint
            let dragEvent = GenericGameGridDragEvent(
                coordinate: dragCoordinate,
                coordinateBegan: dragCoordinate,
                point: dragPoint,
                pointBegan: dragPoint,
                state: .began
            )
            dragDelegate.drag(event: dragEvent, onGrid: self)
        case .changed:
            guard let dragCoordinateBegan, let dragPointBegan else { return }
            var shouldSendContinueEvent = dragDelegate.dragContinuousWanted()
            if let dragCoordinateCurrent, dragCoordinateCurrent != dragCoordinate {
                shouldSendContinueEvent = true
            } else if dragCoordinateBegan != dragCoordinate {
                shouldSendContinueEvent = true
            }
            if shouldSendContinueEvent {
                let dragEvent = GenericGameGridDragEvent(
                    coordinate: dragCoordinate,
                    coordinateBegan: dragCoordinateBegan,
                    point: dragPoint,
                    pointBegan: dragPointBegan,
                    state: .continued
                )
                dragDelegate.drag(event: dragEvent, onGrid: self)
            }
            self.dragCoordinateCurrent = dragCoordinate
            self.dragPointCurrent = dragPoint
        case .ended:
            guard let dragCoordinateBegan, let dragPointBegan else { return }
            let dragEvent = GenericGameGridDragEvent(
                coordinate: dragCoordinate,
                coordinateBegan: dragCoordinateBegan,
                point: dragPoint,
                pointBegan: dragPointBegan,
                state: .ended
            )
            dragDelegate.drag(event: dragEvent, onGrid: self)
            self.dragCoordinateBegan = nil
            self.dragCoordinateCurrent = nil
            self.dragPointBegan = nil
            self.dragPointCurrent = nil
        case .possible, .cancelled, .failed:
            fallthrough
        @unknown default:
            break // unhandled
        }
    }

    private var dragCoordinateBegan: Coordinate?

    private var dragCoordinateCurrent: Coordinate?

    private var dragPointBegan: CGPoint?

    private var dragPointCurrent: CGPoint?

    private var dragRecognizer: UIPanGestureRecognizer?

    @objc private func tapInteraction(sender: UITapGestureRecognizer) {
        guard let tapDelegate else { return }
        let tapPoint = sender.location(in: self)
        guard let tapCoordinate = coordinateForPoint(tapPoint) else {
            return
        }
        tapDelegate.tap(atCoordinate: tapCoordinate, andPoint: tapPoint, onGrid: self)
    }

    private var tapRecognizer: UITapGestureRecognizer?

    // MARK: private grid array stuff

    private func coordinateForPoint(_ point: CGPoint) -> Coordinate? {
        guard CGRectContainsPoint(bounds, point) else {
            return nil
        }
        switch gridType {
        case .fixed, .rectangle, .square:
            return .init(
                x: Int(point.x / gridPixelWidth),
                y: Int(point.y / gridPixelHeight)
            )
        }
    }

    private func pointForCoordinate(_ coordinate: Coordinate) -> CGPoint {
        switch gridType {
        case .fixed, .rectangle, .square:
            return .init(
                x: gridPixelWidth * CGFloat(coordinate.x),
                y: gridPixelHeight * CGFloat(coordinate.y)
            )
        }
    }

    private func setupInitialGridViewArray() {
        if gridViews.count > 0 {
            for view in gridViews.values {
                view.removeFromSuperview()
            }
        }
        gridViews.removeAll()
        for y in 0..<genericGridGame.gridHeight {
            for x in 0..<genericGridGame.gridWidth {
                let coordinate = Coordinate(x: x, y: y)
                let view = ViewType(
                    withState: genericGridGame.stateAt(coordinate: coordinate),
                    andCoordinate: coordinate,
                    inGrid: genericGridGame
                )
                addSubview(view)
                gridViews[coordinate] = view
            }
        }
    }

    private func setupPixelSizes() {
        switch gridType {
        case .fixed(let size):
            gridPixelWidth = size.width
            gridPixelHeight = size.height
        case .rectangle:
            gridPixelWidth = bounds.width / CGFloat(genericGridGame.gridWidth)
            gridPixelHeight = bounds.height / CGFloat(genericGridGame.gridHeight)
        case .square:
            gridPixelWidth = bounds.width / CGFloat(genericGridGame.gridWidth)
            gridPixelHeight = bounds.height / CGFloat(genericGridGame.gridHeight)
            if gridPixelWidth > gridPixelHeight {
                gridPixelWidth = gridPixelHeight
            } else {
                gridPixelHeight = gridPixelWidth
            }
        }
    }

}
