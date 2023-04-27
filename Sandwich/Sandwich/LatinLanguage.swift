import Foundation
import UIKit

public enum LatinLanguage: Int, CaseIterable, Comparable {
  public static func < (lhs: LatinLanguage, rhs: LatinLanguage) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
  
  case english = 0
  case romanian = 1
  case catalan
  case danish
  case german
  case dutch
  case finnish
  case french
  case hungarian
  case indonesian
  case italian
  case latin
  case norwegian
  case malay
  case polish
  case portuguese
  case spanish
  case slovak
  case swedish
  case tagalog
  case turkish
  
  public var code: String {
    switch self {
    case .english: return "en"
    case .romanian: return "ro"
    case .catalan: return "ct"
    case .danish: return "da"
    case .german: return "de"
    case .dutch: return "nl"
    case .finnish: return "fi"
    case .french: return "fr"
    case .hungarian: return "hu"
    case .indonesian: return "id"
    case .italian: return "it"
    case .latin: return "la"
    case .norwegian: return "nb"
    case .malay: return "ms"
    case .polish: return "pl"
    case .portuguese: return "pt"
    case .spanish: return "es"
    case .slovak: return "sk"
    case .swedish: return "sv"
    case .tagalog: return "tl"
    case .turkish: return "tr"
    }
  }
  
  public var name: String {
    switch self {
    case .english: return "English"
    case .romanian: return "Romanian"
    case .catalan: return "Catalan"
    case .danish: return "Danish"
    case .german: return "German"
    case .dutch: return "Dutch"
    case .finnish: return "Finnish"
    case .french: return "French"
    case .hungarian: return "Hungarian"
    case .indonesian: return "Indonesian"
    case .italian: return "Italian"
    case .latin: return "Latin"
    case .norwegian: return "Norwegian Bokmål"
    case .malay: return "Malay"
    case .polish: return "Polish"
    case .portuguese: return "Portuguese"
    case .spanish: return "Spanish"
    case .slovak: return "Slovak"
    case .swedish: return "Swedish"
    case .tagalog: return "Tagalog"
    case .turkish: return "Turkish"
    }
  }
  
  public var appleLocale: String {
    switch self {
    case .english: return "en-US"
    case .romanian: return "ro-RO"
    case .catalan: return "ES-CT"
    case .danish: return "da-DK"
    case .german: return "de-DE"
    case .dutch: return "nl-NL"
    case .finnish: return "fi-FI"
    case .french: return "fr-FR"
    case .hungarian: return "hu-HU"
    case .indonesian: return "id-ID"
    case .italian: return "it-IT"
    case .latin: return "la"
    case .norwegian: return "nb-NO"
    case .malay: return "ms-MY"
    case .polish: return "pl-PL"
    case .portuguese:return "pt-PT"
    case .spanish: return "es-ES"
    case .slovak: return "sk-SK"
    case .swedish: return "sv-SE"
    case .tagalog: return "tl-PH"
    case .turkish: return "tr-TR"
    }
  }
  
  public var emoji: String {
    switch self {
    case .english: return "🇬🇧"
    case .romanian: return "🇷🇴"
    case .catalan: return "🇪🇸"
    case .danish: return "🇩🇰"
    case .german: return "🇩🇪"
    case .dutch: return "🇳🇱"
    case .finnish: return "🇫🇮"
    case .french: return "🇫🇷"
    case .hungarian: return "🇭🇺"
    case .indonesian: return "🇮🇩"
    case .italian: return "🇮🇹"
    case .latin: return "🇻🇦"
    case .norwegian: return "🇳🇴"
    case .malay: return "🇲🇾"
    case .polish: return "🇵🇱"
    case .portuguese:return "🇵🇹"
    case .spanish: return "🇪🇸"
    case .slovak: return "🇸🇰"
    case .swedish: return "🇸🇪"
    case .tagalog: return "🇵🇭"
    case .turkish: return "🇹🇷"
    }
  }
  
  public var flag: UIImage? {
    emoji.image()
  }
  
//  public var emoji: String {
//    code.uppercased().unicodeScalars.map({ 127397 + $0.value }).compactMap(UnicodeScalar.init).map(String.init).joined()
//  }
}

extension String {
  func languageToEmoji(languageCode: String) -> String? {
    let base: UInt32 = 127397
    var scalarView = String.UnicodeScalarView()
    
    for code in languageCode.uppercased().unicodeScalars {
      guard let scalar = UnicodeScalar(base + code.value) else {
        return nil
      }
      scalarView.append(scalar)
    }
    
    return String(scalarView)
  }
}

extension String {
  func image() -> UIImage? {
    let size = CGSize(width: 44, height: 44)
    let rect = CGRect(origin: CGPoint(), size: size)
    return UIGraphicsImageRenderer(size: size).image { context in
      (self as NSString).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 44)])
    }
  }
}
