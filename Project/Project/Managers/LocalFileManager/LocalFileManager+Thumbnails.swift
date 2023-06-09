import UIKit

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
