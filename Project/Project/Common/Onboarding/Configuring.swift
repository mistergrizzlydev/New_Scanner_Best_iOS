import Foundation

internal func Init<Type>(_ value: Type, block: (_ object: Type) -> Void) -> Type {
    block(value)
    return value
}
