import Foundation

//extension FileManager {
//  func createUniqueFolder(at folderURL: URL, withName folderName: String) throws -> URL {
//    var validatedFolderName = folderName
//    var suffixNumber = 1
//
//    // Check if folder name already exists
//    if fileExists(atPath: folderURL.appendingPathComponent(folderName).path) {
//        var folderExists = true
//
//        // If folder already exists, add numerical suffix until unique folder name is found
//        while folderExists {
//            validatedFolderName = "\(folderName) \(suffixNumber)"
//            folderExists = fileExists(atPath: folderURL.appendingPathComponent(validatedFolderName).path)
//            suffixNumber += 1
//        }
//    }
//
//    let newFolderURL = folderURL.appendingPathComponent(validatedFolderName)
//
//    // Create the folder using the validated folder name
//    try createDirectory(at: newFolderURL, withIntermediateDirectories: false, attributes: nil)
//
//    return newFolderURL
//  }
//}

extension FileManager {
  func createUniqueFolder(at folderURL: URL, withName folderName: String) throws -> URL {
    // Validate folder name
    let validatedFolderName = validateFolderName(at: folderURL) ?? "" //validateDocumentTitle(title: folderName, at: folderURL)
    
    // Append validated folder name to folder URL
    let newFolderURL = folderURL.appendingPathComponent(validatedFolderName)
    
    // Create the folder using the validated folder name
    try createDirectory(at: newFolderURL, withIntermediateDirectories: false, attributes: nil)
    
    return newFolderURL
  }
  
  func duplicateFile(at url: URL) throws {
    if url.isDirectory {
      let validatedFileName = validateFolderName(at: url) ?? ""
      let newFileURL = url.appendingPathComponent(validatedFileName)
      
      try FileManager.default.copyItem(at: url, to: newFileURL)
      
    } else {
      guard let fileExtension = url.pathExtension.isEmpty ? nil : url.pathExtension else {
          throw NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError,
                        userInfo: [NSLocalizedDescriptionKey: "File extension not found for \(url.lastPathComponent)"])
      }
      
      let fileName = url.deletingPathExtension().lastPathComponent
      let duplicatedFileName = fileName + " Duplicated." + fileExtension
      let directoryURL = url.deletingLastPathComponent()
      let validatedFileName = validateFolderName(at: directoryURL) ?? "" //validateDocumentTitle(title: duplicatedFileName, at: directoryURL)
      let newFileURL = directoryURL.appendingPathComponent(validatedFileName)
      
      try FileManager.default.copyItem(at: url, to: newFileURL)
    }
  }
  
//  func duplicateFiles(at urls: [URL], withNewName newName: String) throws -> [URL] {
//    var newURLs = [URL]()
//
//    for url in urls {
//      guard let fileExtension = url.pathExtension.isEmpty ? nil : url.pathExtension else {
//        throw NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError,
//                      userInfo: [NSLocalizedDescriptionKey: "File extension not found for \(url.lastPathComponent)"])
//      }
//
//      let fileName = url.deletingPathExtension().lastPathComponent
//      let newFileName = newName + "." + fileExtension
//
//      let directoryURL = url.deletingLastPathComponent()
//
//      let validatedFileName = validateDocumentTitle(title: newFileName, at: directoryURL)
//
//      let newFileURL = directoryURL.appendingPathComponent(validatedFileName).appendingPathExtension(fileExtension)
//
//      try copyItem(at: url, to: newFileURL)
//      newURLs.append(newFileURL)
//    }
//
//    return newURLs
//  }
  
//  private func validateDocumentTitle(title: String, at folderURL: URL) -> String {
//    var validatedTitle = title
//    var suffixNumber = 1
//
//    // Check if file/folder name already exists
//    while fileExists(atPath: folderURL.appendingPathComponent(validatedTitle).path) {
//      // If file/folder already exists, add numerical suffix until unique name is found
//      validatedTitle = "\(title) \(suffixNumber)"
//      suffixNumber += 1
//    }
//
//    return validatedTitle
//  }
}


extension FileManager {
  func delete(_ urls: [URL]) throws {
    try urls.forEach { url in
      try removeItem(at: url)
    }
  }
}

extension FileManager {
  func validateFolderName(at url: URL) -> String? {
    let fileName = url.deletingPathExtension().lastPathComponent
    let pathExtension = url.pathExtension
    
    var validatedName = ""
    var suffixNumber = 1
    
    guard let lastCharacter = fileName.last,
          let name = fileName.components(separatedBy: String(lastCharacter)).first,
          let lastCharacterInt = Int(String(lastCharacter)) else {
      // handle the error case here
      return nil
    }
    
    suffixNumber = lastCharacterInt + 1
    
    if name.last == " " {
      validatedName = constructValidatedName(name: name, suffixNumber: suffixNumber, pathExtension: pathExtension, isDirectory: url.hasDirectoryPath)
    } else {
      validatedName = constructValidatedName(name: "\(name) ", suffixNumber: suffixNumber, pathExtension: pathExtension, isDirectory: url.hasDirectoryPath)
    }
    
    var newURL = url
    newURL = url.deletingLastPathComponent().appendingPathComponent(validatedName)
    
    repeat {
      validatedName = constructValidatedName(name: name, suffixNumber: suffixNumber,
                                             pathExtension: pathExtension,
                                             isDirectory: url.hasDirectoryPath)
      newURL = url.deletingLastPathComponent().appendingPathComponent(validatedName)
      
      suffixNumber += 1
      
    } while fileExists(atPath: newURL.path)
    
    return validatedName
  }
  
  private func constructValidatedName(name: String, suffixNumber: Int, pathExtension: String, isDirectory: Bool) -> String {
    if isDirectory {
      return "\(name)\(suffixNumber)"
    } else {
      return "\(name)\(suffixNumber).\(pathExtension)"
    }
  }
}












































extension FileManager {
  private func validateFolderNameWorkingMixed(at url: URL) -> String {
    if url.hasDirectoryPath {
      let fileName = url.lastPathComponent
      var validatedName = ""
      var suffixNumber = 1
      
      // Check if the last character of the name is an integer
      if let lastCharacter = fileName.last,
         let name = fileName.components(separatedBy: String(lastCharacter)).first,
         let lastCharacterInt = Int(String(lastCharacter)) {

        suffixNumber = lastCharacterInt + 1
        
        if name.last == " " {
          validatedName = "\(name)\(suffixNumber)"
        } else {
          validatedName = "\(name) \(suffixNumber)"
        }
        
        var newURL = url
        newURL = url.deletingLastPathComponent().appendingPathComponent(validatedName)
        
        while fileExists(atPath: newURL.path) {
          guard suffixNumber != 777 else { break }
          suffixNumber += 1
          
          if name.last == " " {
            validatedName = "\(name)\(suffixNumber)"
          } else {
            validatedName = "\(name) \(suffixNumber)"
          }
          
          newURL = url.deletingLastPathComponent().appendingPathComponent(validatedName)
        }
      }
      
      return validatedName
    } else {
      let fileName = url.deletingPathExtension().lastPathComponent
      let pathExtension = url.pathExtension
      
      var validatedName = ""
      var suffixNumber = 1
      
      // Check if the last character of the name is an integer
      if let lastCharacter = fileName.last,
         let name = fileName.components(separatedBy: String(lastCharacter)).first,
         let lastCharacterInt = Int(String(lastCharacter)) {
        
        suffixNumber = lastCharacterInt + 1
        
        if name.last == " " {
          validatedName = "\(name)\(suffixNumber).\(pathExtension)"
        } else {
          validatedName = "\(name) \(suffixNumber).\(pathExtension)"
        }
        
        var newURL = url
        newURL = url.deletingLastPathComponent().appendingPathComponent(validatedName)
        
        while fileExists(atPath: newURL.path) {
          guard suffixNumber != 777 else { break }
          suffixNumber += 1
          
          if name.last == " " {
            validatedName = "\(name)\(suffixNumber).\(pathExtension)"
          } else {
            validatedName = "\(name) \(suffixNumber).\(pathExtension)"
          }
          
          newURL = url.deletingLastPathComponent().appendingPathComponent(validatedName)
        }
      }
      return validatedName
    }
  }
  
  private func validateFolderNameWorks(at url: URL) -> String {
    let fileName = url.deletingPathExtension().lastPathComponent
    let pathExtension = url.pathExtension
    
    var validatedName = ""
    var suffixNumber = 1
    
    // Check if the last character of the name is an integer
    if let lastCharacter = fileName.last,
       let name = fileName.components(separatedBy: String(lastCharacter)).first,
       let lastCharacterInt = Int(String(lastCharacter)) {
      
      suffixNumber = lastCharacterInt + 1
      
      if name.last == " " {
        if url.hasDirectoryPath {
          validatedName = "\(name)\(suffixNumber)"
        } else {
          validatedName = "\(name)\(suffixNumber).\(pathExtension)"
        }
      } else {
        if url.hasDirectoryPath {
          validatedName = "\(name) \(suffixNumber)"
        } else {
          validatedName = "\(name) \(suffixNumber).\(pathExtension)"
        }
      }
      
      var newURL = url
      newURL = url.deletingLastPathComponent().appendingPathComponent(validatedName)
      
      while fileExists(atPath: newURL.path) {
        guard suffixNumber != 777 else { break }
        suffixNumber += 1
        
        if name.last == " " {
          if url.hasDirectoryPath {
            validatedName = "\(name)\(suffixNumber)"
          } else {
            validatedName = "\(name)\(suffixNumber).\(pathExtension)"
          }
        } else {
          if url.hasDirectoryPath {
            validatedName = "\(name) \(suffixNumber)"
          } else {
            validatedName = "\(name) \(suffixNumber).\(pathExtension)"
          }
        }
        
        newURL = url.deletingLastPathComponent().appendingPathComponent(validatedName)
      }
    }
    return validatedName
  }
}
