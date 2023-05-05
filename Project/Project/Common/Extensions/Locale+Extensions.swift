import UIKit

extension Locale {
  func fileNameFromSelectedTags(_ rootURL: URL) -> String {
    let name = Tag.convertToDate(from: UserDefaults.standard.selectedTags)
    let fileName = "\(name).pdf"
    let fileURL = rootURL.appendingPathComponent(fileName)
    
    return FileManager.default.validatedName(at: fileURL) ?? fileName
  }
}
