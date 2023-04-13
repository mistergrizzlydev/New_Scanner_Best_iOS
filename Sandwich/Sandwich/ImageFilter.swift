import UIKit

public class ImageFilter {
  // Apply Noir filter to the image
  public func noirFilter(on image: UIImage) -> UIImage? {
    image.noirFilter()
  }
  
  // Apply Gray filter to the image
  public func grayFilter(on image: UIImage) -> UIImage? {
    image.grayFilter()
  }
  
  // Apply B/W filter to the image
  public func blackAndWhiteFilter(on image: UIImage) -> UIImage? {
    image.blackAndWhiteFilter()
  }
  
  // Apply Magic Color filter to the image
  public func magicColorFilter(on image: UIImage) -> UIImage? {
    image.magicColorFilter()
  }
  
  // Apply Color filter to the image
  public func colorFilter(on image: UIImage) -> UIImage? {
    image.colorFilter()
  }
  
  // Apply Color filter to the image
  public func withTransparentColorLayer(on image: UIImage, transparentColor: UIColor = UIColor.black.withAlphaComponent(0.5)) -> UIImage? {
    image.withTransparentColorLayer(transparentColor: transparentColor)
  }
}
