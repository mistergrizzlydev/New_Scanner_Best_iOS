import UIKit

enum FileManagerAction: Int {
  case rename = 0
  case move
  case copy
  case star
  case share
  case properties
  
  case delete
  
  var defaultIconName: String {
    switch self {
    case .rename: return "pencil"
    case .move: return "arrowshape.turn.up.left"
    case .copy: return "doc.on.doc"
    case .star: return "star"
    case .share: return "square.and.arrow.up"
    case .properties: return "info.circle"
    case .delete: return "trash"
    }
  }
  
  func title(file: Document) -> String {
    switch self {
    case .rename: return "Rename"
    case .move: return "Move to"
    case .copy: return "Copy"
    case .star: return file.isFileStarred() ? "Remove from Starred" : "Add to Starred"
    case .share: return "Share"
    case .properties: return "View details"
    case .delete: return "Delete"
    }
  }
  
  func iconName(file: Document) -> String {
    switch self {
    case .rename: return "pencil"
    case .move: return "arrowshape.turn.up.left"
    case .copy: return "doc.on.doc"
    case .star: return file.isFileStarred() ? "star.slash" : "star"
    case .share: return "square.and.arrow.up"
    case .properties: return "info.circle"
    case .delete: return "trash"
    }
  }
  
  static func allCases(file: Document) -> [FileManagerAction] {
    switch file.type {
    case .file: return [.rename, .move, .copy, .star, .share, .properties]
    case .folder: return [.rename, .move, .star, .share, .properties]
    }
  }
  
  static func createAction(from managerAction: FileManagerAction,
                           viewModel: DocumentsViewModel,
                           handler: @escaping UIActionHandler) -> UIAction {
    UIAction(title: managerAction.title(file: viewModel.file),
             image: UIImage(systemName: managerAction.iconName(file: viewModel.file)),
             handler: handler)
  }
  
  static func createDeleteAction(_ handler: @escaping UIActionHandler) -> UIAction {
    UIAction(title: "Delete",
             image: UIImage(systemName: FileManagerAction.delete.defaultIconName),
             attributes: .destructive,
             handler: handler)
  }
  
  
  /*
   var title: String {
     switch self {
     case .rename: return "Rename"
     case .move: return "Move to"
     case .copy: return "Copy"
     case .star: return "Add to Starred"
     case .share: return "Share"
     case .properties: return "View details"
     }
   }
   */
}
