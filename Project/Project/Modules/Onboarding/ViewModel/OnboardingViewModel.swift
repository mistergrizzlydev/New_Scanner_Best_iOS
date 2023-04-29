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
