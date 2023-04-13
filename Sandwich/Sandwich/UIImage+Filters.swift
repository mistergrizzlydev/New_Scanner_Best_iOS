import UIKit

extension UIImage {
    // Apply Noir filter to the image
    func noirFilter() -> UIImage? {
        let context = CIContext()
        let inputImage = CIImage(image: self)
        
        guard let filter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
        else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    // Apply Gray filter to the image
    func grayFilter() -> UIImage? {
        let context = CIContext()
        let inputImage = CIImage(image: self)
        
        guard let filter = CIFilter(name: "CIPhotoEffectMono") else { return nil }
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
        else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    // Apply B/W filter to the image
    func blackAndWhiteFilter() -> UIImage? {
        let context = CIContext()
        let inputImage = CIImage(image: self)
        
        guard let filter = CIFilter(name: "CIColorControls") else { return nil }
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(0, forKey: kCIInputSaturationKey)
        filter.setValue(1.1, forKey: kCIInputContrastKey)
        
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
        else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    // Apply Magic Color filter to the image
    func magicColorFilter() -> UIImage? {
        let context = CIContext()
        let inputImage = CIImage(image: self)
        
        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        guard let outputImage = filter.outputImage else { return nil }
        
        let cropRect = CGRect(x: 0, y: 0, width: inputImage!.extent.width, height: inputImage!.extent.height)
        guard let invertedImage = context.createCGImage(outputImage.cropped(to: cropRect), from: outputImage.extent) else { return nil }
        
        let maskImage = CIImage(cgImage: invertedImage)
        guard let blendFilter = CIFilter(name: "CIMultiplyCompositing") else { return nil }
        blendFilter.setValue(inputImage, forKey: kCIInputBackgroundImageKey)
        blendFilter.setValue(maskImage, forKey: kCIInputImageKey)
        
        guard let blendedOutput = blendFilter.outputImage,
              let cgImage = context.createCGImage(blendedOutput, from: blendedOutput.extent)
        else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    // Apply Color filter to the image
    func colorFilter() -> UIImage? {
        let context = CIContext()
        let inputImage = CIImage(image: self)
        
        guard let filter = CIFilter(name: "CIPhotoEffectProcess") else { return nil }
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        
        guard let outputImage = filter.outputImage else { return nil }
        
        let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent)
        let filteredImage = UIImage(cgImage: outputCGImage!)
        
        return filteredImage
    }
}

extension UIImage {
  func withTransparentColorLayer(transparentColor: UIColor = UIColor.black.withAlphaComponent(0.5)) -> UIImage? {
      // Create a new image context with the same size as the original image
      UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

      // Draw the original image into the context
      draw(in: CGRect(x: 0, y: 0, width:size.width, height: size.height))

      // Draw the transparent color on top of the original image
      transparentColor.setFill()
      UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))

      // Get the new image from the context
      let newImage = UIGraphicsGetImageFromCurrentImageContext()

      // End the context
      UIGraphicsEndImageContext()
      return newImage
    }
}
