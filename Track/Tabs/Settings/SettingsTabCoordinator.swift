//
//  SettingsTabCoordinator.swift
//  Track
//
//  Created by Marcus Rossel on 18.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Settings Tab Coordinator

/// The coordinator managing everything inside the settings tab.
final class SettingsTabCoordinator: NSObject, Coordinator {
   
   /// A container for retaining all of the sub-coordinators used by the settings tab coordinator.
   private var childCoordinators: [Coordinator] = []
   
   /// The navigation controller managing the coordinator's controllers.
   let navigationController: UINavigationController
   
   /// A reference to the category manager that can be passed to any controllers in need of it.
   let categoryManager: CategoryManager
   
   /// Creates a settings tab coordinator.
   init(
      categoryManager: CategoryManager,
      navigationController: NavigationController = NavigationController()
   ) {
      // Phase 1.
      self.categoryManager = categoryManager
      self.navigationController = navigationController
      
      // Phase 2.
      super.init()
      
      // Phase 3.
      navigationController.addObserver(self)
      navigationController.navigationBar.prefersLargeTitles = true
   }
   
   /// Hands over control to the settings tab coordinator.This causes a settings root controller to
   /// be shown.
   func run() {
      let settingsRootController = makeSettingsRootController()
      navigationController.pushViewController(settingsRootController, animated: true)
   }
}

// MARK: - Controller Creation

extension SettingsTabCoordinator {
   
   /// Creates and sets up a settings root controller.
   private func makeSettingsRootController() -> SettingsRootController {
      let controller = SettingsRootController(delegate: self)
      
      // Sets up the controller's navigation item.
      controller.navigationItem.title = "Settings"
      controller.navigationItem.largeTitleDisplayMode = .always
      
      return controller
   }
}

// MARK: - Navigation Controller Observer

extension SettingsTabCoordinator: NavigationControllerObserver {
   
   /// Makes sure that the navigation bar is behaving correctly, before a settings root controller
   /// is shown.
   func navigationController(
      _ navigationController: NavigationController, willShow controller: UIViewController
   ) {
      // Only acts if the controller to be shown is a settings root controller.
      guard controller is SettingsRootController else { return }
      
      // Makes sure the navigation bar is still shown and setup correctly.
      navigationController.setNavigationBarHidden(false, animated: true)
      navigationController.navigationBar.prefersLargeTitles = true
   }
}

// MARK: - Settings Root Controller Delegate

extension SettingsTabCoordinator: SettingsRootControllerDelegate {

   /// Hands over control to a categories coordinator.
   func settingsRootControllerDidSelectCategories(
      _ settingsRootController: SettingsRootController
   ) {
      // Creates a categories coordinator.
      let categoriesCoordinator = CategoriesCoordinator(
         categoryManager: categoryManager,
         navigationController: navigationController as! NavigationController
      )
      
      // Retains and runs the categories coordinator.
      childCoordinators.append(categoriesCoordinator)
      categoriesCoordinator.run()
   }
}
