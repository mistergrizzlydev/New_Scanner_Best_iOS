//
//  LocalFileManager+Thumbnails.swift
//  Project
//
//  Created by Mister Grizzly on 07.04.2023.
//

import UIKit

enum ImageSize {
  case low
  case medium
  case small
  case original
  
  var sizeValue: CGFloat {
    switch self {
    case .low:
      return 0.25
    case .medium:
      return 0.5
    case .small:
      return 0.75
    case .original:
      return 1.0
    }
  }
}

extension UIImage {
  func jpegData(size: ImageSize) -> Data? {
    jpegData(compressionQuality: size.sizeValue)
  }
}

extension LocalFileManagerDefault {
  func getCreateAndGetThumbnail(fileManager: FileManager = FileManager.default,
                                for url: URL, thumbnailsFolderName: String,
                                size: ImageSize = .medium) -> (url: URL, image: UIImage?) {
    let thumbnail = generateThumbnail(for: url)
    
    let folderURL = url.deletingLastPathComponent()
    let folderThumbnailURL = isRootDirectory(url: url) ? thumbnailsFolderURL : folderURL.appendingPathComponent(thumbnailsFolderName)
    if !isRootDirectory(url: folderURL) {
      setupThumbnailsFolder(url: folderThumbnailURL)
    }
    let fileThumbnailURL = folderThumbnailURL.appendingPathComponent(url.lastPathComponent)
    let finalURL = fileThumbnailURL.deletingPathExtension().appendingPathExtension("jpg")
    if !fileManager.fileExists(atPath: fileThumbnailURL.path) {
      try? thumbnail?.jpegData(size: size)?.write(to: finalURL)
    }
    
    return (finalURL, thumbnail)
  }
}
