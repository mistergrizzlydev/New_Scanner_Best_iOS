import UIKit

final class BaseWindow: UIWindow { }

enum Appearance: String, CaseIterable {
  case system
  case light
  case dark
  
  var name: String {
    return rawValue.capitalized
  }
  
  func apply() {
    switch self {
    case .system:
      UserDefaults.appearance = .system
      apply(with: .unspecified)
    case .light:
      UserDefaults.appearance = .light
      apply(with: .light)
    case .dark:
      UserDefaults.appearance = .dark
      apply(with: .dark)
    }
  }
  
  private func apply(with overrideUserInterfaceStyle: UIUserInterfaceStyle) {
    if let mainWindow = UIApplication.shared.connectedScenes
      .compactMap({ $0 as? UIWindowScene })
      .flatMap({ $0.windows })
      .first(where: { $0.isKeyWindow }) {
      mainWindow.overrideUserInterfaceStyle = overrideUserInterfaceStyle
    }
  }
  
  var overrideUserInterfaceStyle: UIUserInterfaceStyle {
    switch self {
    case .system: return .unspecified
    case .light: return .light
    case .dark: return .dark
    }
  }
}
