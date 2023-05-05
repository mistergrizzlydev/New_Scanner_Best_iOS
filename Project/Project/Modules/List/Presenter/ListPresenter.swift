import UIKit

enum ListType {
  case main
  case detail(URL)
}

protocol ListPresenterProtocol {
  func present()
  func presentNext(from url: URL)
  func move(at indexPath: IndexPath?)
}

final class ListPresenter: ListPresenterProtocol {
  private struct Constants {
    
  }
  
  private weak var view: (ListViewControllerProtocol & UIViewController)!
  private let coordinator: Coordinator
  private let localFileManager: LocalFileManager
  
  private let type: ListType
  private let rootURL: URL
  private let filesToMove: [URL]
  private var url: URL?
  private var whereToMoveURL: URL?
  
  init(view: ListViewControllerProtocol & UIViewController,
       coordinator: Coordinator,
       localFileManager: LocalFileManager,
       type: ListType,
       rootURL: URL,
       filesToMove: [URL]) {
    self.view = view
    self.coordinator = coordinator
    
    self.type = type
    self.localFileManager = localFileManager
    self.rootURL = rootURL
    self.filesToMove = filesToMove
  }
  
  func present() {
    switch type {
    case .main:
      let allFolders = localFileManager.contentsOfDirectory(url: rootURL, sortBy: .name)?.compactMap { $0.url }.filter { $0.isDirectory } ?? []
      let filesToDisplay = allFolders.excluding(filesToMove)
      let viewModels = filesToDisplay.compactMap({ ListViewModel(file: Folder(url: $0)) })
      view.prepare(with: viewModels)
    case .detail:
      let allFolders = localFileManager.contentsOfDirectory(url: rootURL, sortBy: .name)?.compactMap { $0.url }.filter { $0.isDirectory } ?? []
      let viewModels = allFolders.compactMap({ ListViewModel(file: Folder(url: $0)) })
      view.prepare(with: viewModels)
    }
  }
  
  func presentNext(from url: URL) {
    switch type {
    case .main:
      self.whereToMoveURL = url
      
    case .detail(let fileURL):
      self.url = url
      let folders = localFileManager.contentsOfDirectory(url: url, sortBy: .name)?.compactMap { $0.url }.filter { $0.isDirectory } ?? []
      let controller = ListBuilder().buildViewController(type: .detail(fileURL), rootURL: url, filesToMove: [url])!
      guard !folders.isEmpty else { return }
      view.navigationController?.pushViewController(controller, animated: true)
    }
  }
  
  func move(at indexPath: IndexPath?) {
    switch type {
    case .main:
      if let _ = indexPath, let whereToMoveURL = whereToMoveURL {
        
        for move in filesToMove {
          let newMoveURL = whereToMoveURL.appendingPathComponent(move.lastPathComponent)
          do {
            try localFileManager.moveFile(from: move, to: newMoveURL)
          } catch {
            view.showDrop(message: error.localizedDescription, icon: .systemAlert())
          }
        }
      } else {
        for move in filesToMove {
          let newMoveURL = rootURL.appendingPathComponent(move.lastPathComponent)
          do {
            try localFileManager.moveFile(from: move, to: newMoveURL)
          } catch {
            view.showDrop(message: error.localizedDescription, icon: .systemAlert())
          }
        }
      }
      NotificationCenter.default.post(name: .moveFolderOrFile, object: nil)
      view.dismiss(animated: true)
    case .detail(let fileURL):
      if let indexPath = indexPath {
        let toURL = self.url?.appendingPathComponent(fileURL.lastPathComponent) ?? filesToMove[indexPath.row].appendingPathComponent(fileURL.lastPathComponent)
        NotificationCenter.default.post(name: .newFileURL, object: nil, userInfo: ["new_file_url": toURL])
        do {
          try localFileManager.moveFile(from: fileURL, to: toURL)
        } catch {
          view.showDrop(message: error.localizedDescription, icon: .systemAlert())
        }
      } else {
        let rootURL = self.url ?? self.rootURL
        let toDocURL = rootURL.appendingPathComponent(fileURL.lastPathComponent)
        do {
          try localFileManager.moveFile(from: fileURL, to: toDocURL)
          NotificationCenter.default.post(name: .newFileURL, object: nil, userInfo: ["new_file_url": toDocURL])
        } catch {
          view.showDrop(message: error.localizedDescription, icon: .systemAlert())
        }
      }
      view.dismiss(animated: true)
    }
  }
}
