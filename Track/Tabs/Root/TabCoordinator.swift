//
//  TabCoordinator.swift
//  Track
//
//  Created by Marcus Rossel on 16.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

/// The coordinator managing the app's tabbed design.
final class TabCoordinator: NSObject, RootCoordinator {
   
   /// A mapping of tabs to their corresponding coordinators.
   private var tabCoordinators: [Tab: Coordinator]
   
   /// A tab coordinator's root view controller is its tab bar controller.
   var rootViewController: UIViewController {
      return tabBarController
   }
   
   /// The tab bar controller displaying the coordinators content.
   private let tabBarController = UITabBarController()
   
   #warning("Redundancy.")
   /// The tab coordinators navigation controller is redundant.
   let navigationController = UINavigationController()
   
   init(categoryManager: Category.Manager, trackManager: Track.Manager) {
      // Phase 1.
      tabCoordinators = [:]
      
      // Phase 2.
      super.init()
      
      // Phase 3.
      tabCoordinators = makeTabCoordinators(
         categoryManager: categoryManager, trackManager: trackManager
      )
   }
   
   /// Hands over control to the tab coordinator, which causes its tab bar controller's first tab
   /// to be shown.
   func run() {
      // Sets up the tab bar controller's tab view controllers.
      tabBarController.viewControllers = makeTabControllers()
      
      // Selects the timer tab as initially selected.
      // The tab bar controller delegate method is called to cause the corresponding coordinator to
      // run.
      let initialController = tabCoordinators[.timer]!.navigationController
      tabBarController.selectedViewController = initialController
      tabBarController(tabBarController, didSelect: initialController)
   }
   
   /// Creates the coordinators associated with each tab.
   private func makeTabCoordinators(categoryManager: Category.Manager, trackManager: Track.Manager)
   -> [Tab: Coordinator] {
      
      return [
         .timer: TimerTabCoordinator(
            categoryManager: categoryManager, trackManager: trackManager, delegate: self
         ),
         .today: TodayTabCoordinator(
            categoryManager: categoryManager, trackManager: trackManager
         ),
         .record: RecordTabCoordinator(
            categoryManager: categoryManager, trackManager: trackManager
         ),
         .settings: SettingsTabCoordinator(
            categoryManager: categoryManager
         )
      ]
   }
   
   /// Creates the root controllers associated with each tab. The controllers' tab bar items are
   /// setup in the process.
   private func makeTabControllers() -> [UIViewController] {
      // Performs the setup of the navigation controller for each tab and returns the resulting
      // collection.
      return Tab.allCases.map { tab in
         let controller = tabCoordinators[tab]!.navigationController
         
         // Populates each tab controller with its title, icon and tag.
         let item = UITabBarItem(title: tab.title, image: tab.icon, tag: tab.rawValue)
         controller.tabBarItem = item
         
         return controller
      }
   }
}

// MARK: - Tab Bar Controller Delegate

extension TabCoordinator: UITabBarControllerDelegate {
   
   /// The method used to determine from which tab control is handed over to which other tab.
   func tabBarController(
      _ tabBarController: UITabBarController,
      shouldSelect viewController: UIViewController
   ) -> Bool {
      
      // Gets the current tab.
      let currentSelection = tabBarController.selectedIndex
      guard let currentTab = Tab(rawValue: currentSelection) else {
         fatalError("Received invalid tab tag.")
      }
      
      // Gets the tab that was selected.
      let nextSelection = viewController.tabBarItem.tag
      guard let nextTab = Tab(rawValue: nextSelection) else {
         fatalError("Received invalid tab tag.")
      }
      
      #warning("Incomplete.")
      // Do something useful with the information about the current and next tab.
      
      return true
   }
   
   /// Causes the selected controller's (and therefore tab's) coordinator to run.
   func tabBarController(
      _ tabBarController: UITabBarController, didSelect viewController: UIViewController
   ) {
      
      // Gets the selected tab.
      let selection = viewController.tabBarItem.tag
      guard let tab = Tab(rawValue: selection) else { fatalError("Received invalid tab tag.") }
      
      // Hands over control to the selected tab's coordinator.
      tabCoordinators[tab]?.run()
   }
}

// MARK: - Timer Tab Delegate

extension TabCoordinator: TimerTabDelegate {
   
   func colorTabBar(with color: UIColor) {
      tabBarController.tabBar.barTintColor = color
      tabBarController.tabBar.isTranslucent = false
      
      #warning("Incomplete.")
      // Adjust icon color accordingly.
   }
}


