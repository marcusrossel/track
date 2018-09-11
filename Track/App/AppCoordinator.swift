//
//  AppCoordinator.swift
//  Track
//
//  Created by Marcus Rossel on 18.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Coordinator Protocol

/// A coordinator is a type used for navigating between and managing controllers.
protocol Coordinator {
   
   /// A coordinator uses a navigation controller to manage the displaying of content.
   var navigationController: UINavigationController { get }
   
   /// Causes controll to be handed over to the coordinator.
   /// Usually this should cause the coordinator to display an appropriate view.
   func run()
}

// MARK: - App Coordinator

/// The coordinator sitting at the root of the entire app.
/// This coordinator does not confrom to the `Coordinator` protocol, as it behaves slightly
/// differently from "ordinary" coordinators.
final class AppCoordinator: NSObject {
   
   /// The window in which the coordinator will manage content.
   private let window: UIWindow
   
   /// A manager for accessing and writing to persistent data.
   let persistenceManager = PersistenceManager()
   
   /// A collection of sub-coordinators being managed by the app coordinator.
   private var childCoordinators: [Coordinator] = []
   
   /// The root view controller being managed by the app coordinator; therefore also being the app's
   /// root view controller.
   private let rootViewController: UITabBarController

   /// A manager for handeling the collection of existing categories.
   /// The manager is loaded from disk on app launch, or created anew if none was persisted before.
   private lazy var categoryManager: Category.Manager = loadCategoryManager()
   
   /// A manager for handeling the collection of existing tracks.
   /// The manager is loaded from disk on app launch, or created anew if none was persisted before.
   private lazy var trackManager: Track.Manager = loadTrackManager()
   
   /// Initializes an app coordinator from the window in which it will display its content.
   init(window: UIWindow) {
      // Phase 1.
      self.window = window
      rootViewController = UITabBarController()
      
      // Phase 2.
      super.init()
      
      // Phase 3.
      rootViewController.delegate = self
      
      // Sets up all of the coordinators needed for the different tabs and stores them as children.
      childCoordinators = makeTabCoordinators()
   }
   
   /// Hands controller over to the app coordinator, which effectively starts the app.
   func start() {
      // Sets up the tab bar controller's tab view controllers.
      rootViewController.viewControllers = makeTabControllers()
      
      // Selects the first tab as initially selected.
      // The tab bar controller delegate method is called to cause the associated coordinator to
      // run.
      let initialController = childCoordinators[0].navigationController
      rootViewController.selectedViewController = initialController
      tabBarController(rootViewController, didSelect: initialController)
      
      // Sets up and presents the window.
      window.rootViewController = rootViewController
      window.makeKeyAndVisible()
   }
   
   /// Creates the coordinators associated with each tab.
   private func makeTabCoordinators() -> [Coordinator] {
      return [
         TimerTabCoordinator(categoryManager: categoryManager, trackManager: trackManager),
         TodayTabCoordinator(categoryManager: categoryManager, trackManager: trackManager),
         RecordTabCoordinator(categoryManager: categoryManager, trackManager: trackManager),
         SettingsTabCoordinator(categoryManager: categoryManager)
      ]
   }
   
   /// Creates the root controllers associated with each tab (and therefore coordinator).
   /// The controllers' tab bar items are also setup in the process.
   private func makeTabControllers() -> [UIViewController] {
      let tabControllers = childCoordinators.map { $0.navigationController }
      let tabNames = ["Timer", "Today", "Record", "Settings"]
      let tabIcons = [ImageLoader.Icon.timer, .today, .record, .settings]
      
      let imageLoader = ImageLoader()
   
      // Populates each tab controller with its tab name and icon.
      for index in (0...3) {
         let image = imageLoader[icon: tabIcons[index]]
         let item = UITabBarItem(title: tabNames[index], image: image, tag: index)
         tabControllers[index].tabBarItem = item
      }
      
      return tabControllers
   }
}

// MARK: - Tab Bar Controller Delegate

extension AppCoordinator: UITabBarControllerDelegate {
   
   /// Causes the selected controller's (and therefore tab's) coordinator to run.
   func tabBarController(
      _ tabBarController: UITabBarController, didSelect viewController: UIViewController
   ) {
      let tabItemTag = viewController.tabBarItem.tag
      childCoordinators[tabItemTag].run()
   }
}

// MARK: - Persistence

extension AppCoordinator {
   
   /// A convenience method for creating a category manager from the data stored on disk.
   private func loadCategoryManager() -> Category.Manager {
      let categories: [Category]
      
      // Reads the array of categories stored on disk.
      // If no such file is found, the `categories` are set as an empty array.
      // If there were any other errors, a fatal error occurs.
      do { categories = try persistenceManager.read(.categories, as: [Category].self) ?? [] }
      catch { fatalError("Persistence manager was unable to read categories.") }
      
      // Tries to initialize a manager from the loaded array of categories.
      // This can only fail if the loaded categories are in some way invalid. In this case something
      // internal is wrong, and a fatal error occurs.
      guard let categoryManager = Category.Manager(categories: categories) else {
         fatalError("Read invalid categories from disk.")
      }
      
      return categoryManager
   }
   
   /// A convenience method for creating a track manager from the data stored on disk.
   private func loadTrackManager() -> Track.Manager {
      let tracks: Set<Track>
      
      // Reads the array of tracks stored on disk.
      // If no such file is found, the `tracks` are set as an empty array.
      // If there were any other errors, a fatal error occurs.
      do { tracks = try persistenceManager.read(.tracks, as: Set<Track>.self) ?? [] }
      catch {
         fatalError("Persistence manager was unable to read tracks.")
      }
      
      // Tries to initialize a manager from the loaded array of tracks.
      // This can only fail if the loaded tracks are in some way invalid. In this case something
      // internal is wrong, and a fatal error occurs.
      guard let trackManager = Track.Manager(tracks: tracks) else {
         fatalError("Read invalid tracks from disk.")
      }
      
      return trackManager
   }
   
   /// Persists all data that needs to be persisted by the app.
   func persistAllData() {
      do {
         try persistenceManager.write(.categories, value: categoryManager.categories)
         try persistenceManager.write(.tracks, value: trackManager.tracks)
      } catch {
         fatalError("Attempt to persist data failed.")
      }
   }
}
