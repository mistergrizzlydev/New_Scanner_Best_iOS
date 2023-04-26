import UIKit
import os.log

protocol Loggable {
  var logger: Logger { get }
  func zipLogURL() -> URL?
}

extension Loggable {
  var logger: Logger {
    return Logger.shared
  }
}

extension UIView: Loggable {
  func zipLogURL() -> URL? {
    Logger.shared.zipLogURL()
  }
  
  var logger: Logger {
    return Logger.shared
  }
}

extension UIViewController: Loggable {
  var logger: Logger {
    return Logger.shared
  }
  
  func zipLogURL() -> URL? {
    Logger.shared.zipLogURL()
  }
}

enum LogLevel: String {
  case debug = "🐛"
  case info = "💡"
  case warning = "⚠️"
  case error = "🚨"
  case success = "✅"
}

final class Logger {
  static let shared = Logger()
  
  private let logger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "", category: "default")
  private let logDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("Logs")
  
  private init() {
    createLogDirectoryIfNeeded()
  }
  
  private func createLogDirectoryIfNeeded() {
    do {
      try FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: true, attributes: nil)
    } catch let error {
      os_log("Failed to create log directory: %@", log: logger, type: .error, error.localizedDescription)
    }
  }

  /*
   The reason we are not creating a generic function only with the level parameter is that different log types might require different ways of formatting the log message or performing additional tasks such as writing the log to a file or sending it to a remote server. For example, logging an error might require additional information about the stack trace or the underlying cause of the error.

   By having separate functions for each log type, we can customize the behavior and formatting of each log message while keeping the code simple and easy to read. This also allows us to easily add or remove log types as needed without affecting the other log types.
   */
  func log(_ message: String, level: LogLevel = .debug, file: String = #file, function: String = #function, line: Int = #line) {
    let fileName = (file as NSString).lastPathComponent
    let log = "[\(fileName):\(line)] \(function) - \(message)"
    let logLevelString = level.rawValue
    switch level {
    case .debug:
      os_log("%{public}@", log: logger, type: .debug, "\(logLevelString) \(log)")
    case .info:
      os_log("%{public}@", log: logger, type: .info, "\(logLevelString) \(log)")
    case .warning:
      os_log("%{public}@", log: logger, type: .info, "\(logLevelString) \(log)")
    case .error:
      os_log("%{public}@", log: logger, type: .error, "\(logLevelString) \(log)")
    case .success:
      os_log("%{public}@", log: logger, type: .info, "\(logLevelString) \(log)")
    }
  }
  
  // old implementation
  //  func log(_ message: String, type: OSLogType = .default, file: String = #file, function: String = #function, line: Int = #line) {
  //    let fileName = (file as NSString).lastPathComponent
  //    let log = "[\(fileName):\(line)] \(function) - \(message)"
  //    os_log("%{public}@", log: logger, type: type, "\(LogLevel(rawValue: "\(type)")?.rawValue ?? "") \(log)")
  //  }
  //
  //  func logError(_ error: Error, file: String = #file, function: String = #function, line: Int = #line) {
  //    log("❌ Error: \(error.localizedDescription)", type: .error, file: file, function: function, line: line)
  //  }
  //
  //  func logWarning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
  //    log("⚠️ Warning: \(message)", type: .info, file: file, function: function, line: line)
  //  }
  //
  //  func logSuccess(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
  //    log("✅ Success: \(message)", type: .info, file: file, function: function, line: line)
  //  }
    
}


import SSZipArchive

extension Logger {
  func zipLogURL() -> URL? {
    // Create a temporary directory to store the log files
    let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("Logs")
    
    do {
      // Get all the log files in the log directory
      let logFiles = try FileManager.default.contentsOfDirectory(at: Logger.shared.logDirectory, includingPropertiesForKeys: nil)
      
      // Create the temporary directory if it doesn't exist
      try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true, attributes: nil)
      
      // Copy the log files to the temporary directory
      for logFile in logFiles {
        let destinationURL = tempDirectory.appendingPathComponent(logFile.lastPathComponent)
        try FileManager.default.copyItem(at: logFile, to: destinationURL)
      }
      
      // Create a zip file with the log files
      let zipPath = tempDirectory.appendingPathComponent("logs.zip").path
      let success = SSZipArchive.createZipFile(atPath: zipPath, withContentsOfDirectory: tempDirectory.path)
      
      if success {
        // Return the URL of the zip file
        return URL(fileURLWithPath: zipPath)
      } else {
        // Handle error
        return nil
      }
    } catch {
      // Handle error
      return nil
    }
  }
}

//extension Logger {
//  func zipLog() -> URL? {
//      let dateFormatter = DateFormatter()
//      dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
//      let dateString = dateFormatter.string(from: Date())
//
//      let zipFilePath = logDirectory.appendingPathComponent("\(dateString).zip")
//
//      do {
//          let fileManager = FileManager.default
//          let contents = try fileManager.contentsOfDirectory(atPath: logDirectory.path)
//
//          let archive = Archive(url: zipFilePath, accessMode: .create)
//          for file in contents {
//              let filePath = logDirectory.appendingPathComponent(file)
//              try archive.addEntry(with: filePath.lastPathComponent, relativeTo: logDirectory, compressionMethod: .none, bufferSize: 4096, provider: { (position, size) -> Data in
//                  let fileHandle = try FileHandle(forReadingFrom: filePath)
//                  defer { fileHandle.closeFile() }
//                  fileHandle.seek(toFileOffset: UInt64(position))
//                  return fileHandle.readData(ofLength: size)
//              })
//          }
//
//          return zipFilePath
//      } catch let error {
//          logError(error)
//          return nil
//      }
//  }
//
//}
//extension Logger {
//  func zipLog() -> URL? {
//      let dateFormatter = DateFormatter()
//      dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
//      let dateString = dateFormatter.string(from: Date())
//      let zipFileName = "\(dateString).zip"
//      let zipFilePath = logDirectory.appendingPathComponent(zipFileName)
//
//      let fileManager = FileManager.default
//      let logsDirectoryUrl = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("Logs")
//
//      guard let logsDirectoryPath = logsDirectoryUrl.path as NSString? else {
//          logError(NSError(domain: "Logger", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not create logs directory path."]))
//          return nil
//      }
//
//      let fileUrls = try? fileManager.contentsOfDirectory(atPath: logsDirectoryPath as String)
//          .filter { $0.hasSuffix(".log") }
//          .map { URL(fileURLWithPath: logsDirectoryPath.appendingPathComponent($0) as String) }
//
//      guard let files = fileUrls else {
//          logError(NSError(domain: "Logger", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not get file URLs."]))
//          return nil
//      }
//
//      guard !files.isEmpty else {
//          logWarning("No log files found to zip.")
//          return nil
//      }
//
//      guard let zipArchive = Archive(url: zipFilePath, accessMode: .create) else {
//          logError(NSError(domain: "Logger", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not create zip archive."]))
//          return nil
//      }
//
//      for file in files {
//          do {
//              let data = try Data(contentsOf: file)
//              try zipArchive.addEntry(with: file.lastPathComponent, type: .file, uncompressedSize: UInt32(data.count), bufferSize: 4096, provider: { position, size -> Data in
//                  return data.subdata(in: position..<position+size)
//              })
//          } catch let error {
//              logError(error)
//          }
//      }
//
//      return zipFilePath
//  }
//}


//  func zipLog() -> URL? {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
//            let dateString = dateFormatter.string(from: Date())
//
//            let zipFilePath = logDirectory.appendingPathComponent("\(dateString).zip")
//
//            do {
//                try Zip.zipFiles(paths: [logDirectory], zipFilePath: zipFilePath, password: nil, progress: nil)
//                return zipFilePath
//            } catch let error {
//                logError(error)
//                return nil
//            }
//    nil
//  }

