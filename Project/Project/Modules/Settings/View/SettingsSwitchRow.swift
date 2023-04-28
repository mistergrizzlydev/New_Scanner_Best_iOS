import QuickTableViewController
import UIKit

/// A class that represents a row with a switch.
final class SettingsSwitchRow<T: UITableViewCell>: SwitchRowCompatible, Equatable {
  // MARK: - Row
  
  /// The text of the row.
  let text: String
  
  /// The detail text of the row.
  let detailText: DetailText?
  
  let isPro: Bool
  
  /// A closure that will be invoked when the `switchValue` is changed.
  let action: ((Row) -> Void)?
  
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
  
  // MARK: - Initializer
  
  /// Initializes a `SwitchRow` with a title, a switch state and an action closure.
  /// The detail text, icon and the customization closure are optional.
  init(
    text: String,
    detailText: DetailText? = nil,
    switchValue: Bool,
    icon: Icon? = nil,
    isPro: Bool,
    customization: ((UITableViewCell, Row & RowStyle) -> Void)? = nil,
    action: ((Row) -> Void)?
  ) {
    self.text = text
    self.detailText = detailText
    self.switchValue = switchValue
    self.icon = icon
    self.isPro = isPro
    self.customize = customization
    self.action = action
  }
  
  // MARK: - SwitchRowCompatible
  
  /// The state of the switch.
  var switchValue: Bool = false {
    didSet {
      guard switchValue != oldValue else {
        return
      }
      DispatchQueue.main.async {
        self.action?(self)
      }
    }
  }
  
#if os(iOS)
  
  /// The default accessory type is `.none`.
  let accessoryType: UITableViewCell.AccessoryType = .none
  
  /// The `SwitchRow` should not be selectable.
  let isSelectable: Bool = false
  
#elseif os(tvOS)
  /// Returns `.checkmark` when the `switchValue` is on, otherwise returns `.none`.
  var accessoryType: UITableViewCell.AccessoryType {
    return switchValue ? .checkmark : .none
  }
  
  /// The `SwitchRow` is selectable on tvOS.
  let isSelectable: Bool = true
#endif
  
  /// The additional customization during cell configuration.
  let customize: ((UITableViewCell, Row & RowStyle) -> Void)?
  
  // MARK: - Equatable
  
  /// Returns true iff `lhs` and `rhs` have equal titles, detail texts, switch values, and icons.
  static func == (lhs: SettingsSwitchRow, rhs: SettingsSwitchRow) -> Bool {
    return
    lhs.text == rhs.text &&
    lhs.detailText == rhs.detailText &&
    lhs.switchValue == rhs.switchValue &&
    lhs.icon == rhs.icon
  }
}
