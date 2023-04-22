import UIKit
/// Data structure representing the result of the detection of a quadrilateral.
private struct RectangleDetectorResult {
  
  /// The detected quadrilateral.
  let rectangle: Quadrilateral
  
  /// The size of the image the quadrilateral was detected on.
  let imageSize: CGSize
}
