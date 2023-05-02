import Photos
import PhotosUI

extension PHPhotoLibrary {
    enum AuthorizationStatus {
        case authorized
        case limited
        case notDetermined
        case denied
        case restricted
    }
    
    static func checkAuthorizationStatus(completion: @escaping (AuthorizationStatus) -> Void) {
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            switch status {
            case .authorized:
                completion(.authorized)
            case .limited:
                completion(.limited)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    DispatchQueue.main.async {
                        if status == .authorized {
                            completion(.authorized)
                        } else {
                            completion(.denied)
                        }
                    }
                }
            case .denied:
                completion(.denied)
            case .restricted:
                completion(.restricted)
            @unknown default:
                break
            }
        } else {
            let status = PHPhotoLibrary.authorizationStatus()
            if status == .authorized {
                completion(.authorized)
            } else {
                completion(.denied)
            }
        }
    }
}
