//
//  AppContainer.swift
//  Project
//
//  Created by Mister Grizzly on 06.04.2023.
//

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
  
   func registerMainCoordinator(window: UIWindow?, navigationController: UINavigationController) {
     container.register(Coordinator.self) { _ in
       return MainCoordinator(window: window, navigationController: navigationController)
     }
  }
}
