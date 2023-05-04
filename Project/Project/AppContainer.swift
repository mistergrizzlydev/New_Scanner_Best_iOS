import Swinject

final class AppContainer {
  
  static let shared = AppContainer()
  
  let container: Container
  
  private init() {
    container = Container()
    registerDependencies()
  }
  
  private func registerDependencies() {
    // Register your dependencies here
    
    container.register(LocalFileManager.self) { _ in
      return LocalFileManagerDefault()
    }
    
    // Add more dependencies as needed
  }
  
   func registerMainCoordinator(window: BaseWindow?, navigationController: UINavigationController) {
     container.register(Coordinator.self) { _ in
       return MainCoordinator(window: window, navigationController: navigationController)
     }
  }
}
