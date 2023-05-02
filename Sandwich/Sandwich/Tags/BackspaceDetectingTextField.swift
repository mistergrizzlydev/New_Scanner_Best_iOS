import UIKit

protocol BackspaceDetectingTextFieldDelegate: UITextFieldDelegate {
    /// Notify whenever the backspace key is pressed
    func textFieldDidDeleteBackwards(_ textField: UITextField)
}

open class BackspaceDetectingTextField: UITextField {

    open var onDeleteBackwards: (() -> Void)?

    init() {
        super.init(frame: CGRect.zero)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func deleteBackward() {
        onDeleteBackwards?()
        // Call super afterwards. The `text` property will return text prior to the delete.
        super.deleteBackward()
    }
}
