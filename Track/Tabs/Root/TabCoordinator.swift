//
//  TabCoordinator.swift
//  Track
//
//  Created by Marcus Rossel on 16.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Tab Coordinator

/// The coordinator managing the app's tabbed design.
final class TabCoordinator: NSObject, RootCoordinator, Broadcaster {
   
   /// A mapping of tabs to their corresponding coordinators.
   private var tabCoordinators: EnumMap<Tab, Coordinator>!
   
   /// A mapping of tabs to a boolean, indicating whether or not the tab's coordinator has run yet.
   private var runHistory = EnumMap<Tab, Bool> { _ in false }
   
   /// A tab coordinator's root view controller is its tab bar controller.
   var rootViewController: UIViewController {
      return tabBarController
   }
   
   /// The tab bar controller displaying the coordinators content.
   private let tabBarController = UITabBarController()
   
   /// The container storing the instances observing the coordinator.
   var observers: [ObjectIdentifier: Weak<AnyTabCoordinatorObserver>] = [:]
   
   #warning("Redundant.")
   /// The tab coordinators navigation controller is redundant.
   let navigationController = UINavigationController()
   
   init(categoryManager: CategoryManager, trackManager: TrackManager) {
      // Phase 2.
      super.init()
      
      // Phase 3.
      tabBarController.delegate = self
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
      let initialController = tabCoordinators[.timer].navigationController
      tabBarController.selectedViewController = initialController
      tabBarController(tabBarController, didSelect: initialController)
   }
   
   /// Creates the coordinators associated with each tab.
   private func makeTabCoordinators(categoryManager: CategoryManager, trackManager: TrackManager)
   -> EnumMap<Tab, Coordinator> {
      
      return [
         .timer: TimerTabCoordinator(
            categoryManager: categoryManager, trackManager: trackManager
         ),
         .today: TodayTabCoordinator(
            trackManager: trackManager
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
         let controller = tabCoordinators[tab].navigationController
         
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
      
      notifyObservers { $0.selectedTabWillChange(from: currentTab, to: nextTab) }
      return true
   }
   
   /// Causes the selected controller's (and therefore tab's) coordinator to run.
   func tabBarController(
      _ tabBarController: UITabBarController, didSelect viewController: UIViewController
   ) {
      // Gets the selected tab.
      let selection = viewController.tabBarItem.tag
      guard let tab = Tab(rawValue: selection) else { fatalError("Received invalid tab tag.") }
      
      // Runs the selected tab's coordinator, if it has not run before.
      guard runHistory[tab] == false else { return }
      
      tabCoordinators[tab].run()
      runHistory[tab] = true
   }
}

// MARK: - Tab Coordinator Observer

#warning("Unused.")
protocol TabCoordinatorObserver: ObserverType {
   
   func selectedTabWillChange(from origin: Tab, to destination: Tab)
}

extension TabCoordinatorObserver {
   
   func selectedTabWillChange(from origin: Tab, to destination: Tab) { }
}

/// A workaround for the missing ability of protocol existentials to conform to protocols.
final class AnyTabCoordinatorObserver: TabCoordinatorObserver {
   
   private let observer: TabCoordinatorObserver
   
   init(_ observer: TabCoordinatorObserver) {
      self.observer = observer
   }
   
   func selectedTabWillChange(from origin: Tab, to destination: Tab) {
      observer.selectedTabWillChange(from: origin, to: destination)
   }
}
