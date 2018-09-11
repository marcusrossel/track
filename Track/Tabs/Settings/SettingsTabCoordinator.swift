//
//  SettingsTabCoordinator.swift
//  Track
//
//  Created by Marcus Rossel on 18.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Settings Tab Coordinator

final class SettingsTabCoordinator: Coordinator {
   
   private var hasRunBefore = false
   
   private var childCoordinators: [Coordinator] = []
   let navigationController = UINavigationController()
   
   let categoryManager: Category.Manager
   
   init(categoryManager: Category.Manager) {
      self.categoryManager = categoryManager
   }
   
   func run() {
      defer { hasRunBefore = true }
      guard !hasRunBefore else { return }
      
      let settingsRootController = SettingsRootController(delegate: self)
      navigationController.pushViewController(settingsRootController, animated: true)
   }
}

// MARK: - Settings Root Controller Delegate

extension SettingsTabCoordinator: SettingsRootControllerDelegate {
   
   func setupNavigationBar(for controller: SettingsRootController) {
      controller.navigationItem.title = "Settings"
      controller.navigationItem.largeTitleDisplayMode = .always
      navigationController.navigationBar.prefersLargeTitles = true
      navigationController.setNavigationBarHidden(false, animated: true)
   }
   
   func didSelectCategories() {
      let categoriesCoordinator = CategoriesCoordinator(
         categoryManager: categoryManager, navigationController: navigationController
      )
      
      childCoordinators.append(categoriesCoordinator)
      categoriesCoordinator.run()
   }
}
