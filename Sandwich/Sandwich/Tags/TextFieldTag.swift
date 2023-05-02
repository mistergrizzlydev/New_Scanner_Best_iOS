import Foundation
// https://github.com/whitesmith/WSTagsField

public struct TextFieldTag: Hashable {

    public let text: String
    public let context: AnyHashable?

    public init(_ text: String, context: AnyHashable? = nil) {
        self.text = text
        self.context = context
    }

    public func equals(_ other: TextFieldTag) -> Bool {
        return self.text == other.text && self.context == other.context
    }

}

public func == (lhs: TextFieldTag, rhs: TextFieldTag) -> Bool {
    return lhs.equals(rhs)
}
