import UIKit
import QuickTableViewController

// We probably need to create a child of NavigationRow class, and approach with isProVersion
final class SettingsSection: Section {
  let isPro: Bool
  
  init(title: String?, rows: [Row & RowStyle], footer: String? = nil, isPro: Bool) {
    self.isPro = isPro
    super.init(title: title, rows: rows, footer: footer)
  }
}

/// A class that represents a row that triggers certain navigation when selected.
final class SettingsNavigationRow<T: UITableViewCell>: NavigationRowCompatible, Equatable {
  // MARK: - Initializer
  
  #if os(iOS)
  let cell: T
  
  /// Designated initializer on iOS. Returns a `NavigationRow` with a text and a detail text.
  /// The icon, customization, action and accessory button action closures are optional.
  init(
    text: String,
    detailText: DetailText,
    icon: Icon? = nil,
    isPro: Bool,
    customization: ((UITableViewCell, Row & RowStyle) -> Void)? = nil,
    action: ((Row) -> Void)? = nil,
    accessoryButtonAction: ((Row) -> Void)? = nil
  ) {
    self.cell = T()
    self.text = text
    self.detailText = detailText
    self.icon = icon
    self.isPro = isPro
    self.customize = customization
    self.action = action
    self.accessoryButtonAction = accessoryButtonAction
  }
  
  #elseif os(tvOS)
  
  /// Designated initializer on tvOS. Returns a `NavigationRow` with a text and a detail text.
  /// The icon, customization and action closures are optional.
  init(
    text: String,
    detailText: DetailText,
    icon: Icon? = nil,
    customization: ((UITableViewCell, Row & RowStyle) -> Void)? = nil,
    action: ((Row) -> Void)? = nil
  ) {
    self.text = text
    self.detailText = detailText
    self.icon = icon
    self.customize = customization
    self.action = action
  }
  
    #endif
  
  // MARK: - Row
  
  /// The text of the row.
  let text: String
  
  /// The detail text of the row.
  let detailText: DetailText?
  
  /// A closure that will be invoked when the row is selected.
  let action: ((Row) -> Void)?
  
    #if os(iOS)
  let isPro: Bool

  /// A closure that will be invoked when the accessory button is selected.
  let accessoryButtonAction: ((Row) -> Void)?
  
    #endif
  
  // MARK: - RowStyle
  
  /// The type of the table view cell to display the row.
  let cellType: UITableViewCell.Type = T.self
  
  /// Returns the reuse identifier of the table view cell to display the row.
  var cellReuseIdentifier: String {
    return T.reuseIdentifier + (detailText?.style.stringValue ?? "")
  }
  
  /// Returns the table view cell style for the specified detail text.
  var cellStyle: UITableViewCell.CellStyle {
    return detailText?.style ?? .default
  }
  
  /// The icon of the row.
  let icon: Icon?
  
  /// Returns the accessory type with the disclosure indicator when `action` is not nil,
  /// and with the detail button when `accessoryButtonAction` is not nil.
  var accessoryType: UITableViewCell.AccessoryType {
    #if os(iOS)
    switch (action, accessoryButtonAction) {
    case (nil, nil):      return .none
    case (.some, nil):    return .disclosureIndicator
    case (nil, .some):    return .detailButton
    case (.some, .some):  return .detailDisclosureButton
    }
    #elseif os(tvOS)
    return (action == nil) ? .none : .disclosureIndicator
    #endif
  }
  
  /// The `NavigationRow` is selectable when action is not nil.
  var isSelectable: Bool {
    return action != nil
  }
  
  /// The additional customization during cell configuration.
  let customize: ((UITableViewCell, Row & RowStyle) -> Void)?
  
  // MARK: Equatable
  
  /// Returns true iff `lhs` and `rhs` have equal titles, detail texts and icons.
  static func == (lhs: SettingsNavigationRow, rhs: SettingsNavigationRow) -> Bool {
    return
    lhs.text == rhs.text &&
    lhs.detailText == rhs.detailText &&
    lhs.icon == rhs.icon
  }
}

internal extension UITableViewCell.CellStyle {
  var stringValue: String {
    switch self {
    case .default:    return ".default"
    case .subtitle:   return ".subtitle"
    case .value1:     return ".value1"
    case .value2:     return ".value2"
    @unknown default: return ".default"
    }
  }
}
