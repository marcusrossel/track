//
//  AppCoordinator.swift
//  Track
//
//  Created by Marcus Rossel on 18.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - App Coordinator

/// The coordinator sitting at the root of the entire app.
/// This coordinator does not confrom to the `Coordinator` protocol, as it behaves slightly
/// differently from "ordinary" coordinators.
final class AppCoordinator {
   
   /// The window in which the coordinator will manage content.
   private let window: UIWindow
   
   /// A collection of sub-coordinators being managed by the app coordinator.
   private var childCoordinators: [RootCoordinator] = []
   
   /// A manager for accessing and writing data instances that are or need to be stored on disk.
   private let storageManager = StorageManager()
   
   /// A manager for handeling the collection of existing categories.
   /// The manager is loaded from disk on app launch, or created anew if none was persisted before.
   private lazy var categoryManager: CategoryManager = storageManager.loadCategoryManager()
   
   /// A manager for handeling the collection of existing tracks.
   /// The manager is loaded from disk on app launch, or created anew if none was persisted before.
   private lazy var trackManager: TrackManager = storageManager.loadTrackManager()
   
   /// Initializes an app coordinator from the window in which it will display its content.
   init(window: UIWindow) {
      self.window = window
   }
   
   /// Hands controller over to the app coordinator, which effectively starts the app.
   func start() {
      // Sets up the tab coordinator.
      let tabCoordinator = TabCoordinator(
         categoryManager: categoryManager, trackManager: trackManager
      )
      childCoordinators.append(tabCoordinator)
      
      // Sets up and presents the window.
      window.rootViewController = tabCoordinator.rootViewController
      window.makeKeyAndVisible()
      
      tabCoordinator.run()
   }
   
   func persistAllData() {
      storageManager.persist(categoryManager)
      storageManager.persist(trackManager)
   }
}
