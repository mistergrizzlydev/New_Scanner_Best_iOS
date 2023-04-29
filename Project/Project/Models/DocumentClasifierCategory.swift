import Foundation

enum DocumentClasifierCategory: Int {
  case receipt
  case invoice
  case form
  case letter
  
  case id
  case businessCard
  case news
  case music
  
  case handwritten
  case unknown
  
  static var allCases: [DocumentClasifierCategory] {
    [.receipt, .invoice, .form, .letter,
     .id, .businessCard, .news, .music,
     .handwritten, .unknown]
  }
  
  var name: String {
    switch self {
    case .receipt:
      return "Receipt"
    case .invoice:
      return "Invoice or Bill"
    case .form:
      return "Form"
    case .letter:
      return "Letter"
    case .id:
      return "ID"
    case .businessCard:
      return "Business Card"
    case .news:
      return "Book or Magazine"
    case .music:
      return "Music Sheet"
    case .handwritten:
      return "Paper Note"
    case .unknown:
      return "Other"
    }
  }
  
  var image: String {
    switch self {
    case .receipt:
      return "doc.plaintext"
    case .invoice:
      return "doc.text.below.ecg"
    case .form:
      return "doc.richtext"
    case .letter:
      return "envelope.open"
    case .id:
      return "person.crop.rectangle"
    case .businessCard:
      return "person.crop.square.filled.and.at.rectangle"
    case .news:
      return "book"
    case .music:
      return "music.note.list"
    case .handwritten:
      return "note.text"
    case .unknown:
      return "tag.slash"
    }
  }
  
  init?(classification: String) {
    switch classification.lowercased() {
    case "invoice", "invoice or bill".lowercased():
      self = .invoice
    case "receipt".lowercased():
      self = .receipt
    case "music", "music sheet".lowercased():
      self = .music
    case "id".lowercased():
      self = .id
    case "HandWritten".lowercased(), "Note".lowercased(), "Paper note".lowercased():
      self = .handwritten
    case "Form".lowercased():
      self = .form
    case "News".lowercased(), "Book or Magazine".lowercased(): // books or magazine comes here
      self = .news
    case "Unknown".lowercased():
      self = .unknown
    case "Letter".lowercased():
      self = .letter
    case "Business Card".lowercased():
      self = .businessCard
    default:
      return nil
    }
  }
}
