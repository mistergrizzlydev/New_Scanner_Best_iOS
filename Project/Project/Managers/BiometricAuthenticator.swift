import LocalAuthentication
import UIKit

//struct BiometricAuthenticator {
//  enum AuthenticationType {
//    case faceID
//    case touchID
//  }
//
//  private let context = LAContext()
//  // UIDevice.current.biometricType.name
//
//  let aaa = UIDevice.current.biometricType
//  func authenticate(type: AuthenticationType, completion: @escaping (Bool, Error?) -> Void) {
//    var error: NSError?
//    var policy: LAPolicy = .deviceOwnerAuthentication
//
//    switch type {
//    case .faceID:
//      policy = .deviceOwnerAuthenticationWithBiometrics
//    case .touchID:
//      policy = .deviceOwnerAuthenticationWithBiometrics
//    }
//
//    if context.canEvaluatePolicy(policy, error: &error) {
//      context.evaluatePolicy(policy, localizedReason: "Authenticate with \(type)") { (success, error) in
//        DispatchQueue.main.async {
//          completion(success, error)
//        }
//      }
//    } else {
//      DispatchQueue.main.async {
//        completion(false, error)
//      }
//    }
//  }
//}

//import LocalAuthentication

struct BiometricAuthenticator {
  enum AuthenticationType {
    case faceID
    case touchID
  }
  static func authenticateUser(type: AuthenticationType, completion: @escaping (Bool, Error?) -> Void) {
    
    let context = LAContext()
    
    // Check if biometric authentication is available
    var error: NSError?
    guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
      completion(false, error)
      return
    }
    
    // Try biometric authentication first, and fall back to passcode authentication if not available
    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "reason") { (success, error) in
      if success {
        completion(true, nil)
      } else {
        if let laError = error as? LAError, laError.code == .userFallback {
          // User tapped "Enter Password", present the system passcode screen
          self.showSystemPasscodeScreen(reason: "reason", fallbackTitle: "fallbackTitle", completion: completion)
        } else {
          completion(false, error)
        }
      }
    }
  }
  
  private static func showSystemPasscodeScreen(reason: String, fallbackTitle: String?, completion: @escaping (Bool, Error?) -> Void) {
    
    let context = LAContext()
    
    guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) else {
      completion(false, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Passcode authentication not available"]))
      return
    }
    
    var title = fallbackTitle ?? "Enter Passcode"
    if let fallbackButtonTitle = context.localizedFallbackTitle {
      title = fallbackButtonTitle
    }
    
    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { (success, error) in
      if success {
        completion(true, nil)
      } else {
        completion(false, error)
      }
    }
  }
}

