import PDFKit

extension PDFDocument {
  func reSave() {
    // Save the rearranged PDF document
    guard let documentURL = documentURL else { return }
    try? FileManager.default.removeItem(atPath: documentURL.pathExtension)
    
    do {
      try dataRepresentation()?.write(to: documentURL, options: .atomic)
    } catch {
      debugPrint("cannot save ", error.localizedDescription)
    }
  }
}

extension PDFDocument {
  func getImages(size: CGSize = CGSize(width: 150, height: 250), completion: @escaping ([Int: UIImage]) -> Void) {
    let images = NSMutableDictionary()
    let queue = DispatchQueue(label: "pdfToImageQueue", qos: .userInitiated)
    let group = DispatchGroup()
    let serialQueue = DispatchQueue(label: "serialQueue")
    
    for pageNumber in 0..<self.pageCount {
      group.enter()
      queue.async {
        guard let page = self.page(at: pageNumber) else {
          group.leave()
          return
        }
        guard let cgImage = page.thumbnail(of: size, for: .artBox).cgImage else { return } // artBox // mediaBox
        let image = UIImage(cgImage: cgImage)
        serialQueue.async {
          images[NSNumber(value: pageNumber)] = image
          group.leave()
        }
      }
    }
    
    group.notify(queue: DispatchQueue.main) {
      var result = [Int: UIImage]()
      for (pageNumber, image) in images {
        if let pageNumber = pageNumber as? Int, let image = image as? UIImage, image != NSNull() {
          result[pageNumber] = image
        }
      }
      completion(result)
    }
  }
}

extension PDFDocument {
  func toImages(size: CGSize = CGSize(width: 150, height: 250)) -> [UIImage] {
    var images = [UIImage]()
    for pageNumber in 0..<self.pageCount {
      guard let page = self.page(at: pageNumber) else {
        continue
      }
      
      let image = UIImage(cgImage: page.thumbnail(of: size, for: .mediaBox).cgImage!)
      images.append(image)
    }
    
    return images
  }
}

extension PDFDocument {
  var isSandwichPDF: Bool {
    for i in 0..<pageCount {
      guard let page = page(at: i), let pageRef = page.pageRef else {
        continue
      }
      
      guard let allowsCopying = pageRef.document?.allowsCopying else {
        continue
      }
      
      if allowsCopying {
        return true
      }
    }
    
    return false
  }
}

extension PDFDocument {
  func append(_ url: URL) throws {
    guard let pdfURL = self.documentURL, let pdfDocument = PDFDocument(url: url) else {
      throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: [NSLocalizedDescriptionKey: "Invalid PDF URL"])
    }
    
    for pageIndex in 0..<pdfDocument.pageCount {
      if let page = pdfDocument.page(at: pageIndex) {
        self.insert(page, at: self.pageCount)
      }
    }
    
    try dataRepresentation()?.write(to: pdfURL)
  }
}
