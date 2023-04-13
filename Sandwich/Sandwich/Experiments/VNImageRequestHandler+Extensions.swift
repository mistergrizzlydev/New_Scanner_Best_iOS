//
//  VNImageRequestHandler+Extensions.swift
//  Project
//
//  Created by Mister Grizzly on 08.04.2023.
//
//  copied from https://github.com/CombineExtensions/CxVision/blob/499a8455c89c7ffd7479be99130b694c0ea38d1d/CxVision/Source/VNImageRequestHandler%2BCx.swift
// copied from https://github.com/CombineExtensions/CxVision/blob/499a8455c89c7ffd7479be99130b694c0ea38d1d/CxVision/Source/Configuration.swift
import Vision
import Combine
import CoreImage

enum VisionError: Error {
  case unexpectedResultType
}

extension VNImageRequestHandler {
  /// Creates a publisher based on the provided Configuration
  /// - Parameter configuration: Configuration<A: VNRequest, B: VNObservation>.
  func publisher<Request: VNRequest, Observation: VNObservation>(for configuration: Configuration<Request, Observation>) -> AnyPublisher<[Observation], Error> {
    var requests = [VNRequest]()
    
    let visionFuture = Future<[Observation], Error> { promise in
      var visionRequest = Request { (request, error) in
        if let error = error { return promise(.failure(error)) }
        
        guard let results = request.results as? [Observation] else {
          return promise(.failure(VisionError.unexpectedResultType))
        }
        
        return promise(.success(results))
      }
      
      configuration.configure(&visionRequest)
      requests.append(visionRequest)
    }
    
    let performPublisher = Future { promise in promise(Result { try self.perform(requests) }) }
    
    return performPublisher
      .combineLatest(visionFuture)
      .map { _, results in results }
      .eraseToAnyPublisher()
  }
  
  /// Creates a publisher that performs a collection of Vision operations.
  /// - Parameter requestTypes: The types of Vision requests to perform
  ///
  /// This is the only way to perform a batch of operations on the same request handler, which unfortunately does not support customization.
  func publisher(for requestTypes: [VNImageBasedRequest.Type]) -> AnyPublisher<[VNObservation], Error> {
    var requests = [VNImageBasedRequest]()
    
    let futures = Publishers.MergeMany<Future<[VNObservation], Error>>(
      requestTypes.map { requestType -> Future<[VNObservation], Error> in
        Future { promise in
          let request = requestType.init { request, error in
            if let error = error { return promise(.failure(error)) }
            
            guard let results = request.results as? [VNObservation] else {
              return promise(.failure(VisionError.unexpectedResultType))
            }
            
            return promise(.success(results))
          }
          requests.append(request)
        }
      }
    )
    
    let performPublisher = Future { promise in promise(Result { try self.perform(requests) }) }
    
    return performPublisher
      .combineLatest(futures)
      .map { _, results in results }
      .eraseToAnyPublisher()
  }
}

/// A struct for holding onto a configuration function to be applied to a `VNRequest`
///
/// The VNObservation type parameter is used for typecasting in the VNImageRequestHandler extension method `publisher(for:)`
/// to return a publisher that emits the expected VNObservation subclass. If you prefer to typecast at the callsite, a `SimpleConfiguration<A: VNRequest>`
/// typealias is provided
struct Configuration<A: VNRequest, B: VNObservation> {
  let configure: (inout A) -> ()
  
  /// Configuration initializer
  /// - Parameter configuration: The configuration function to apply the to VNRequest.
  ///
  /// *An example Configuration initialization:*
  /// ```
  /// let recognizeTextConfig = Configuration<VNRecognizeTextRequest, VNRecognizedTextObservation> { request in
  ///   request.minimumTextHeight = 10.0
  ///   request.recognitionLevel = .fast
  ///   request.regionOfInterest = CGRect(origin: .zero, size: CGSize(width: 0.50, height: 0.50)
  ///   request.prefersBackgroundProcessing = true
  /// }
  /// ```
  init(_ configuration: @escaping (inout A) -> ()) {
    configure = configuration
  }
}

typealias SimpleConfiguration<A: VNRequest> = Configuration<A, VNObservation>

extension Configuration where A == VNCoreMLRequest {
  init(model: VNCoreMLModel, _ configuration: @escaping (inout A) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = A(model: model, completionHandler: completionHandler)
      configuration(&request)
    }
  }
}

extension Configuration where A == VNTrackRectangleRequest {
  init(rectangleObservation: VNRectangleObservation, _ configuration: @escaping (inout A) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = A(rectangleObservation: rectangleObservation, completionHandler: completionHandler)
      configuration(&request)
    }
  }
}

extension Configuration where A == VNTrackObjectRequest {
  init(detectedObjectObservation: VNDetectedObjectObservation, _ configuration: @escaping (inout A) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = A(detectedObjectObservation: detectedObjectObservation, completionHandler: completionHandler)
      configuration(&request)
    }
  }
}

extension Configuration where A: VNTargetedImageRequest {
  init(targetedCGImage: CGImage, options: [VNImageOption: Any] = [:], orientation: CGImagePropertyOrientation, _ configuration: @escaping (inout A) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = A(targetedCGImage: targetedCGImage, orientation: orientation, options: options, completionHandler: completionHandler)
      configuration(&request)
    }
  }
  
  init(targetedCGImage: CGImage, options: [VNImageOption: Any] = [:], _ configuration: @escaping (inout A) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = A(targetedCGImage: targetedCGImage, options: options, completionHandler: completionHandler)
      configuration(&request)
    }
  }
  
  init(targetedCIImage: CIImage, options: [VNImageOption: Any] = [:], orientation: CGImagePropertyOrientation, _ configuration: @escaping (inout A) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = A(targetedCIImage: targetedCIImage, orientation: orientation, options: options, completionHandler: completionHandler)
      configuration(&request)
    }
  }
  
  init(targetedCIImage: CIImage, options: [VNImageOption: Any] = [:], _ configuration: @escaping (inout A) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = A(targetedCIImage: targetedCIImage, options: options, completionHandler: completionHandler)
      configuration(&request)
    }
  }
  
  init(targetedCVPixelBuffer: CVPixelBuffer, options: [VNImageOption: Any] = [:], orientation: CGImagePropertyOrientation, _ configuration: @escaping (inout A) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = A(targetedCVPixelBuffer: targetedCVPixelBuffer, orientation: orientation, options: options, completionHandler: completionHandler)
      configuration(&request)
    }
  }
  
  init(targetedCVPixelBuffer: CVPixelBuffer, options: [VNImageOption: Any] = [:], _ configuration: @escaping (inout A) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = A(targetedCVPixelBuffer: targetedCVPixelBuffer, options: options, completionHandler: completionHandler)
      configuration(&request)
    }
  }
  
  init(targetedImageData: Data, options: [VNImageOption: Any] = [:], orientation: CGImagePropertyOrientation, _ configuration: @escaping (inout A) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = A(targetedImageData: targetedImageData, orientation: orientation, options: options, completionHandler: completionHandler)
      configuration(&request)
    }
  }
  
  init(targetedImageData: Data, options: [VNImageOption: Any] = [:], _ configuration: @escaping (inout A) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = A(targetedImageData: targetedImageData, options: options, completionHandler: completionHandler)
      configuration(&request)
    }
  }
  
  init(targetedImageURL: URL, options: [VNImageOption: Any] = [:], orientation: CGImagePropertyOrientation, _ configuration: @escaping (inout A) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = A(targetedImageURL: targetedImageURL, orientation: orientation, options: options, completionHandler: completionHandler)
      configuration(&request)
    }
  }
  
  init(targetedImageURL: URL, options: [VNImageOption: Any] = [:], _ configuration: @escaping (inout A) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = A(targetedImageURL: targetedImageURL, options: options, completionHandler: completionHandler)
      configuration(&request)
    }
  }
}

import CoreML

/// - Tag: ThresholdProvider
/// Class providing customized thresholds for object detection model
class ThresholdProvider: MLFeatureProvider {
  /// The actual values to provide as input
  ///
  /// Create ML Defaults are 0.45 for IOU and 0.25 for confidence.
  /// Here the IOU threshold is relaxed a little bit because there are
  /// sometimes multiple overlapping boxes per die.
  /// Technically, relaxing the IOU threshold means
  /// non-maximum-suppression (NMS) becomes stricter (fewer boxes are shown).
  /// The confidence threshold can also be relaxed slightly because
  /// objects look very consistent and are easily detected on a homogeneous
  /// background.
  open var values = [
    "iou_threshold": MLFeatureValue(double: 0.3),
    "score_threshold": MLFeatureValue(double: 0.25)
  ]
  
  init(){
  }
  
  /// The feature names the provider has, per the MLFeatureProvider protocol
  var featureNames: Set<String> {
    return Set(values.keys)
  }
  
  /// The actual values for the features the provider can provide
  func featureValue(for featureName: String) -> MLFeatureValue? {
    return values[featureName]
  }
}
