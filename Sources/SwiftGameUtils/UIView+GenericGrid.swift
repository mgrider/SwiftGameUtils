import UIKit

/// This protocol defines a public interface for a `UIView` subclass that you define that can
/// customize its appearance based on an `associatedtype StateType`.
///
/// StateType should conform to the `GenericGridGameStateProtocol`.
public protocol GenericGridStateUIViewProtocol: UIView {

    associatedtype StateType: GenericGridGameStateProtocol

    init(
        withState state: StateType,
        andCoordinate coordinate: Coordinate
    )

    func setupView(
        forState state: StateType,
        atCoordinate coordinate: Coordinate
    )

}

/// Defines a public interface for the view that holds a grid of subviews, managing
/// their position, as well as interactions.
///
/// For now, this view should be a subclass of `UIViewGenericGrid`.
public protocol GenericGameGridUIViewProtocol: UIView {

    associatedtype StateType: GenericGridGameStateProtocol

    var genericGridGame: GenericGridGame<StateType> { get set }

    func refreshViewPositionsAndStates()

    func refreshViewPosition(at coordinate: Coordinate)

    func refreshViewState(at coordinate: Coordinate)

}

/// A `UIView` subclass, meant to be extended for your application, that holds a grid of subviews
/// that each correspond to a `Coordinate` in a `GenericGridGame`.
///
/// Each of the subviews should conform to `GenericGridStateUIViewProtocol`, and thus
/// know how to draw itself according to its state and coordinate details.
open class UIViewGenericGrid<ViewType: GenericGridStateUIViewProtocol>: UIView, GenericGameGridUIViewProtocol {

    // MARK: embedded types

    public enum SubviewLayoutType {
        /// A fixed size. Each subview in the grid will be the associated `CGSize` value.
        case fixed(CGSize)
        /// A grid with rectangular subviews whose size is based on the total size of the grid divided by
        /// the game's height and width.
        case rectangle
        /// A grid with square subviews with width & height equal to the smaller dimension, based on
        /// the total view size divided by the game's height and width.
        case square
    }

    // MARK: properties

    /// more accurately the "point" height of each subview
    var gridPixelHeight: CGFloat = 0

    /// more accurately the "point" width of each subview
    var gridPixelWidth: CGFloat = 0

    /// how the grid elements will look
    var gridType: SubviewLayoutType = .square

    /// a dictionary of the subviews in this grid, keyed on their `Coordinate` values.
    var gridViews: [Coordinate: ViewType] = [:]

    // MARK: init

    public init(
        genericGridGame: GenericGridGame<ViewType.StateType>,
        gridType: SubviewLayoutType = .square,
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
            let point = pixelPointForCoordinate(coordinate)
            let size = CGSize(width: gridPixelWidth, height: gridPixelHeight)
            view.frame = .init(origin: point, size: size)
        }
    }

    public func refreshViewState(at coordinate: Coordinate) {
        guard let view = gridViews[coordinate] else { return }
        let state = genericGridGame.stateAt(coordinate: coordinate)
        view.setupView(forState: state, atCoordinate: coordinate)
    }

    // MARK: internal

    private func pixelPointForCoordinate(_ coordinate: Coordinate) -> CGPoint {
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
                    andCoordinate: coordinate
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
