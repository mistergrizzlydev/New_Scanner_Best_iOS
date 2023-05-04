import Foundation

extension Notification.Name {
    static let newFileURL = Notification.Name(rawValue: "com.example.app.newFileURL")
    static let moveFolderOrFile = Notification.Name(rawValue: "com.example.app.moveFolderOrFile")
}

extension Notification.Name {
  static let rearrangeScreenDeletePage = Notification.Name("RearrangeScreenDeletePage")
  static let rearrangeScreenDeleteLastPage = Notification.Name("RearrangeScreenDeleteLastPage")
}

extension Notification.Name {
  static let selectableScreenDidSelectOption = Notification.Name("SelectableScreenDidSelectOption")
}

extension Notification.Name {
  static let smartCategorySelected = Notification.Name("SmartCategorySelected")
}
