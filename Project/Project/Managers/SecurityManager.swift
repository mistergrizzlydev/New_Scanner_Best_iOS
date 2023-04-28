import LocalAuthentication
import UIKit

class SecurityManager {
  
  let context = LAContext()
  
  func canEvaluatePolicy() -> Bool {
    return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
  }
  
  func authenticateUser(completion: @escaping (Bool) -> Void) {
    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate with \(UIDevice.current.biometricType.name)") { success, error in
      if success {
        DispatchQueue.main.async {
          completion(true)
        }
      } else {
        DispatchQueue.main.async {
          completion(false)
        }
      }
    }
  }
  
  func lockApp() {
    // Lock the app
  }
  
  func unlockApp() {
    // Unlock the app
  }
}


/*
// In AppDelegate:

func applicationDidEnterBackground(_ application: UIApplication) {
  let securityManager = SecurityManager()
  if securityManager.canEvaluatePolicy() {
    securityManager.authenticateUser { success in
      if !success {
        // Present a locking screen
        securityManager.lockApp()
      }
    }
  } else {
    // Biometric authentication is not available, lock the app
    securityManager.lockApp()
  }
}

// In other parts of the app:

let securityManager = SecurityManager()

// To lock the app:
securityManager.lockApp()

// To unlock the app:
if securityManager.canEvaluatePolicy() {
  securityManager.authenticateUser { success in
    if success {
      securityManager.unlockApp()
    }
  }
}
*/
