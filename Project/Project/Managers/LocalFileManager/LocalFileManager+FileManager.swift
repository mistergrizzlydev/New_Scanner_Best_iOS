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
    let validatedFolderName = validateDocumentTitle(title: folderName, at: folderURL)
    
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
  
  private func validateDocumentTitle(title: String, at folderURL: URL) -> String {
    var validatedTitle = title
    var suffixNumber = 1

    // Check if file/folder name already exists
    while fileExists(atPath: folderURL.appendingPathComponent(validatedTitle).path) {
      // If file/folder already exists, add numerical suffix until unique name is found
      validatedTitle = "\(title) \(suffixNumber)"
      suffixNumber += 1
    }

    return validatedTitle
  }
}

extension LocalFileManager {
  func duplicateFiles(_ urls: [URL]) throws {
    try FileManager.default.duplicateFiles(urls)
  }
}

extension FileManager {
  func duplicateFiles(_ urls: [URL]) throws {
    for url in urls {
      if let validatedName = validateFolderName(at: url) {
        let newFileURL = url.deletingLastPathComponent().appendingPathComponent(validatedName)
        try copyItem(at: url, to: newFileURL)
      }
      
//      let newDirectoryURL = url.deletingLastPathComponent().appendingPathComponent("\(name) - Duplicated")
//
//      var isDirectory: ObjCBool = false
//      let fileExists = self.fileExists(atPath: url.path, isDirectory: &isDirectory)
//
//      guard fileExists && isDirectory.boolValue else {
//        throw NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError, userInfo: nil)
//      }
//
//      guard let enumerator = self.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey],
//                                             options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants]) else {
//        throw NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError, userInfo: nil)
//      }
//
//      do {
//        try self.createDirectory(at: newDirectoryURL, withIntermediateDirectories: true, attributes: nil)
//
//        while let file = enumerator.nextObject() as? String {
//          let fileURL = URL(fileURLWithPath: file, relativeTo: url)
//          let newFileURL = newDirectoryURL.appendingPathComponent(fileURL.lastPathComponent)
//          try self.copyItem(at: fileURL, to: newFileURL)
//        }
//
//      } catch {
//        print(error.localizedDescription)
//      }
    }
  }
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
    var suffixNumber = 0
    
    if let lastCharacter = fileName.last,
          let name = fileName.components(separatedBy: String(lastCharacter)).first,
       let lastCharacterInt = Int(String(lastCharacter)) {
      
      
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
    } else {
      let name = url.deletingPathExtension().lastPathComponent
      suffixNumber += 1
      
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
  }
  
  private func constructValidatedName(name: String, suffixNumber: Int, pathExtension: String, isDirectory: Bool) -> String {
    if isDirectory {
      return "\(name) \(suffixNumber)"
    } else {
      return "\(name) \(suffixNumber).\(pathExtension)"
    }
  }
}

extension FileManager {
  func mergeFolders(urls: [URL], to destinationFolderUrl: URL) throws -> URL? {
    do {
      // If the destination folder already exists, delete it
      if fileExists(atPath: destinationFolderUrl.path) {
        try removeItem(at: destinationFolderUrl)
      }
      
      // Create the new destination folder
      try createDirectory(at: destinationFolderUrl, withIntermediateDirectories: true, attributes: nil)
      
      // Recursively copy the contents of each source folder to the destination folder
      for sourceUrl in urls {
        try copyContentsOfFolder(at: sourceUrl, to: destinationFolderUrl)
      }
      
      // Return the URL of the new destination folder
      return destinationFolderUrl
      
    } catch {
      return nil
    }
  }
  
  private func copyContentsOfFolder(at sourceUrl: URL, to destinationUrl: URL) throws {
    let contents = try contentsOfDirectory(at: sourceUrl, includingPropertiesForKeys: nil, options: [])
    
    for item in contents {
      let destinationUrl = destinationUrl.appendingPathComponent(item.lastPathComponent)
      
      if fileExists(atPath: item.path, isDirectory: nil) {
        // If the item is a folder, recursively copy its contents to the destination folder
        try copyContentsOfFolder(at: item, to: destinationUrl)
      } else {
        // If the item is a file, copy it to the destination folder
        try copyItem(at: item, to: destinationUrl)
      }
    }
  }
}

extension LocalFileManager {
  func mergeFolders(urls: [URL], with folderName: String, toRootURL url: URL) {
    let fileManager = FileManager.default
    let folderURL = url.appendingPathComponent(folderName)
    let validatedName = fileManager.validateFolderName(at: folderURL)
    
    if let validatedName = validatedName {
      do {
        _ = try fileManager.mergeFolders(urls: urls, to: url.appendingPathComponent(validatedName))
      } catch {
        print("error: ", error.localizedDescription)
      }
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

extension FileManager {
  func search(in url: URL, for name: String) -> [URL] {
    var results = [URL]()
    
    guard let enumerator = enumerator(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants]) else {
      return results
    }
    
    while let fileURL = enumerator.nextObject() as? URL {
      if fileURL.lastPathComponent.lowercased().contains(name.lowercased()) {
        results.append(fileURL)
      }
    }
    
    return results
  }
}
