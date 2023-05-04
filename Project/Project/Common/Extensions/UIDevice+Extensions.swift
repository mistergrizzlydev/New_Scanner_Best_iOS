import LocalAuthentication
import UIKit
import AVFoundation

extension UIDevice {
  enum BiometricType {
    case none
    case touchID
    case faceID
    
    var name: String {
      switch self {
      case .none:
        return "None"
      case .touchID:
        return "Touch ID"
      case .faceID:
        return "Face ID"
      }
    }
  }
  
  var biometricType: BiometricType {
    let context = LAContext()
    var error: NSError?
    let biometricType: BiometricType
    
    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
      if #available(iOS 11.0, *) {
        switch context.biometryType {
        case .none:
          biometricType = .none
        case .touchID:
          biometricType = .touchID
        case .faceID:
          biometricType = .faceID
        @unknown default:
          biometricType = .none
        }
      } else {
        biometricType = .touchID
      }
    } else {
      biometricType = .none
    }
    
    return biometricType
  }
}

extension UIDevice {
  static func hasFlash() -> Bool {
    if let device = AVCaptureDevice.default(for: .video) {
      return device.hasTorch
    }
    return false
  }
}
