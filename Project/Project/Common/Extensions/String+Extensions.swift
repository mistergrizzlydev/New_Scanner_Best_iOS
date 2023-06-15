import Foundation

extension String {
  var encrypted: String {
    let result = try? encrypt()
    return result ?? ""
  }
  
  var decrypted: String {
    let result = try? decrypt()
    return result ?? ""
  }
}

extension String {
  var isValidEmail: Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: self)
  }
}

extension String {
  /**
   Error parsing methods
   */
  var toError: Error {
    return NSError(domain: "",
                   code: 1299,
                   userInfo: [NSLocalizedDescriptionKey: self])
  }
  
  var localized: String{
    return NSLocalizedString(self, comment: "")
  }
}
