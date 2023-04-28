import Foundation

struct OnboardingViewModel {
  let title: String
  let skip: String
  let done: String
  let categories: [OnboardingCategory]
}

//enum OnboardingCategory: String, CaseIterable {
//    case student = "I am...a student"
//    case employee = "I am...an employee"
//    case businessOwner = "I am...a business owner"
//    case freelancer = "I am...a freelancer"
//    case parent = "I am...a parent"
//    case traveler = "I am...a traveler"
//
//    var popularFolderNames: [String] {
//        switch self {
//        case .student:
//            return ["Class Notes", "Assignments", "Exams", "Projects", "Reference Materials"]
//        case .employee:
//            return ["Company Policies", "Training Materials", "Performance Reviews", "Benefits Information", "Client Communications"]
//        case .businessOwner:
//            return ["Invoices", "Receipts", "Contracts", "Marketing Materials", "Employee Records", "Expenses"]
//        case .freelancer:
//            return ["Project Briefs", "Invoices", "Receipts", "Communication Logs", "Portfolio"]
//        case .parent:
//            return ["School Information", "Medical Records", "Activities and Sports", "Emergency Contacts", "Homework"]
//        case .traveler:
//            return ["Itinerary", "Tickets and Passports", "Hotel Reservations", "Activities and Tours", "Travel Insurance", "Expenses"]
//        }
//    }
//}

//enum OnboardingCategory: String, CaseIterable {
//  case skip = "Choose your option"
//  case student = "I am...a student"
//  case employee = "I am...an employee"
//  case businessOwner = "I am...a business owner"
//  case freelancer = "I am...a freelancer"
//  case parent = "I am...a parent"
//  case traveler = "I am...a traveler"
//
//  var popularFolderNames: [String] {
//    switch self {
//    case .student:
//      return ["Class Notes", "Assignments", "Exams", "Projects", "Reference Materials"]
//    case .employee:
//      return ["Company Policies", "Training Materials", "Performance Reviews", "Benefits Information", "Client Communications"]
//    case .businessOwner:
//      return ["Invoices", "Receipts", "Contracts", "Marketing Materials", "Employee Records", "Expenses", "Scanned Documents"]
//    case .freelancer:
//      return ["Project Briefs", "Invoices", "Receipts", "Communication Logs", "Portfolio", "Scanned Documents"]
//    case .parent:
//      return ["School Information", "Medical Records", "Activities and Sports", "Emergency Contacts", "Homework", "Scanned Documents"]
//    case .traveler:
//      return ["Itinerary", "Tickets and Passports", "Hotel Reservations", "Activities and Tours", "Travel Insurance", "Expenses", "Scanned Documents"]
//    case .skip:
//      return []
//    }
//  }
//}


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
