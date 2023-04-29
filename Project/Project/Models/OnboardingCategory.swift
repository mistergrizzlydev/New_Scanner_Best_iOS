import UIKit

enum OnboardingCategory: Int, CaseIterable, Comparable {
  static func < (lhs: OnboardingCategory, rhs: OnboardingCategory) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
  
  case skip = 0
  case student
  case employee
  case businessOwner
  case freelancer
  case parent
  case traveler
  
  var category: String {
    switch self {
    case .skip:
      return "No category"
    case .student:
      return "Student"
    case .employee:
      return "Employee"
    case .businessOwner:
      return "Business Owner"
    case .freelancer:
      return "Freelancer"
    case .parent:
      return "Parent"
    case .traveler:
      return "Traveler"
    }
  }
  
  var settingsCategory: String {
    switch self {
    case .skip:
      return "No category selected"
    case .student:
      return "Student"
    case .employee:
      return "Employee"
    case .businessOwner:
      return "Business Owner"
    case .freelancer:
      return "Freelancer"
    case .parent:
      return "Parent"
    case .traveler:
      return "Traveler"
    }
  }
  
  var settingsName: String {
    switch self {
    case .student:
      return "I am...a student!"
    case .employee:
      return "I am...an employee!"
    case .businessOwner:
      return "I am...a business owner!"
    case .freelancer:
      return "I am...a freelancer!"
    case .parent:
      return "I am...a parent!"
    case .traveler:
      return "I am...a traveler!"
    case .skip:
      return "You haven't chosen any category."
    }
  }
  
  var name: String {
    switch self {
    case .student:
      return "I am...a student"
    case .employee:
      return "I am...an employee"
    case .businessOwner:
      return "I am...a business owner"
    case .freelancer:
      return "I am...a freelancer"
    case .parent:
      return "I am...a parent"
    case .traveler:
      return "I am...a traveler"
    case .skip:
      return "Choose your option"
    }
  }
  
  var popularFolderNames: [String] {
    switch self {
    case .student:
      return ["Class notes", "Assignments", "Reference Material"]
    case .employee:
      return ["Pay stubs", "Performance reviews", "Expense reports"]
    case .businessOwner:
      return ["Invoices", "Receipts", "Expenses"]
    case .freelancer:
      return ["Contracts", "Invoices", "Receipts"]
    case .parent:
      return ["School forms", "Medical records", "Artwork"]
    case .traveler:
      return ["Passport", "Boarding pass", "Itinerary"]
    case .skip:
      return ["General", "Personal", "Work"]
    }
  }
}

