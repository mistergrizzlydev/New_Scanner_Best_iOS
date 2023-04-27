import Foundation

enum PageSize: String {
  case letter
  case legal
  case tabloid
  case ledger
  case A4
  case A5
  case A6
  case A3
  case businessCard = "Business Card"
  case auto

  var name: String {
    rawValue.capitalized
  }
  
  var sizeInPoints: CGSize {
    switch self {
    case .letter:
      return CGSize(width: 612, height: 792)
    case .legal:
      return CGSize(width: 612, height: 1008)
    case .tabloid:
      return CGSize(width: 792, height: 1224)
    case .ledger:
      return CGSize(width: 1224, height: 792)
    case .A4:
      return CGSize(width: 595, height: 842)
    case .A5:
      return CGSize(width: 421, height: 595)
    case .A6:
      return CGSize(width: 298, height: 421)
    case .A3:
      return CGSize(width: 842, height: 1191)
    case .businessCard:
      return CGSize(width: 288, height: 162)
    case .auto:
      return CGSize.zero
    }
  }
  
  var sizeInMillimeters: String {
    switch self {
    case .letter:
      return "215.9 x 279.4 mm"
    case .legal:
      return "215.9 x 355.6 mm"
    case .tabloid:
      return "279.4 x 431.8 mm"
    case .ledger:
      return "279.4 x 431.8 mm"
    case .A4:
      return "210 x 297 mm"
    case .A5:
      return "148 x 210 mm"
    case .A6:
      return "105 x 148 mm"
    case .A3:
      return "297 x 420 mm"
    case .businessCard:
      return "85 x 55 mm"
    case .auto:
      return ""
    }
  }
  
  static var allCases: [PageSize] {
    [.auto, .A4, .letter, .legal, .A3, .A5, .A6, .ledger, .tabloid, .businessCard]
  }
}
