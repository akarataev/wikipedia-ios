import UIKit

public protocol BatchEditNavigationDelegate: NSObjectProtocol {
    func didChange(editingState: BatchEditingState, rightBarButton: UIBarButtonItem)
    func didSetIsBatchEditToolbarVisible(_ isVisible: Bool)
    var batchEditToolbar: UIToolbar { get }
    func createBatchEditToolbar(with items: [UIBarButtonItem], setVisible visible: Bool)
    func emptyStateDidChange(_ empty: Bool)
}

public class BatchEditSelectView: SizeThatFitsView {
    
    fileprivate var multiSelectIndicator: UIImageView?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        createSubview()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isSelected: Bool = false {
        didSet {
            updateMultiSelectIndicatorImage()
        }
    }
    
    fileprivate func updateMultiSelectIndicatorImage() {
        let image = isSelected ? UIImage(named: "selected", in: Bundle.main, compatibleWith: nil) : UIImage(named: "unselected", in: Bundle.main, compatibleWith: nil)
        multiSelectIndicator?.image = image
    }
    
    public override var frame: CGRect {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var fixedWidth: CGFloat = 60
    
    public override func sizeThatFits(_ size: CGSize, apply: Bool) -> CGSize {
        let superSize = super.sizeThatFits(size, apply: apply)
        if (apply) {
            multiSelectIndicator?.frame = CGRect(x: 0, y: 0, width: fixedWidth, height: size.height)
        }
        let width = superSize.width == UIViewNoIntrinsicMetric ? fixedWidth : superSize.width
        let height = superSize.height == UIViewNoIntrinsicMetric ? 50 : superSize.height
        return CGSize(width: width, height: height)
    }
    
    fileprivate func createSubview() {
        for view in subviews {
            view.removeFromSuperview()
        }
        
        let multiSelectIndicator = UIImageView()
        multiSelectIndicator.backgroundColor = .clear
        insertSubview(multiSelectIndicator, at: 0)
        multiSelectIndicator.contentMode = .left
        self.multiSelectIndicator = multiSelectIndicator
        updateMultiSelectIndicatorImage()

        backgroundColor = multiSelectIndicator.backgroundColor
        setNeedsLayout()
    }

}

public enum BatchEditingState {
    case none
    case open
    case cancelled
    case inactive // swipe action is open
}

public enum BatchEditToolbarActionType {
    case update, addToList, unsave, delete
        
    public func action(with target: Any?) -> BatchEditToolbarAction {
        var title: String = "Update"
        var type: BatchEditToolbarActionType = .update
        switch self {
        case .addToList:
            title = "Add to list"
            type = .addToList
        case .unsave:
            title = "Un-save"
            type = .unsave
        case .delete:
            title = "Delete"
            type = .delete
        default:
            break
        }
        let button = UIBarButtonItem(title: title, style: .plain, target: target, action: #selector(ActionDelegate.didPerformBatchEditToolbarAction(_:)))
        return BatchEditToolbarAction(title: title, type: type, button: button, target: target)
    }
}

public class BatchEditToolbarAction: UIAccessibilityCustomAction {
    let title: String
    public let type: BatchEditToolbarActionType
    public let button: UIBarButtonItem
    
    public init(title: String, type: BatchEditToolbarActionType, button: UIBarButtonItem, target: Any?) {
        self.title = title
        self.type = type
        self.button = button
        let selector = button.action ?? #selector(ActionDelegate.didPerformBatchEditToolbarAction(_:))
        super.init(name: title, target: target, selector: selector)
    }
}

public protocol BatchEditableCell: NSObjectProtocol {
    var batchEditingTranslation: CGFloat { get set }
    var batchEditSelectView: BatchEditSelectView? { get }
    func layoutIfNeeded() // call to layout views after setting batch edit translation
}
