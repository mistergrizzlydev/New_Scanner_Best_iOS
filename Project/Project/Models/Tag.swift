import Foundation

enum Tag: String, Decodable, Encodable {
  case day, month, year, date, time, seconds, invoice, scan
  
  var name: String {
    rawValue.capitalized
  }
  
  var component: String {
    switch self {
    case .day:
      return "dd"
    case .month:
      return "MM"
    case .year:
      return "yyyy"
    case .date:
      return "MMM dd yyyy, hh:mm:ss a"
    case .time:
      return "hh:mm a"
    case .seconds:
      return "ss"
    case .invoice:
      return "'Invoice'"
    case .scan:
      return "'Scan'"
    }
  }
  
  static var allCases: [Tag] = [.day, .month, .year, .date, .time, .seconds, .invoice, .scan]
  
  static func convertToDate(from tags: [Tag]) -> String {
    debugPrint("convert", tags.count, tags)
    let formatter = DateFormatter()
    var dateFormat = ""
    for tag in tags {
      dateFormat += tag.component
      if tag != tags.last {
        dateFormat += "-"
      }
    }
    
    formatter.dateFormat = dateFormat
    return formatter.string(from: Date())
  }
}

extension Array where Element == Tag {
  mutating func insert(_ tag: Tag) {
    if !contains(tag) {
      append(tag)
    }
  }
  
  mutating func remove(_ tag: Tag) {
    if let index = firstIndex(of: tag) {
      remove(at: index)
    }
  }
}


//func toDate() -> String {
//  let formatter = DateFormatter()
//  formatter.dateFormat = "MMM dd yyyy, hh:mm:s a"
//  let dateString = formatter.string(from: Date())
//  let fileName = "Scan \(dateString)"
//  return fileName
//}
