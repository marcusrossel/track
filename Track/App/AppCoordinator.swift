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
final class AppCoordinator: RootCoordinator {
   
   /// The window in which the coordinator will manage content.
   private let window: UIWindow
   
   /// The root coordinator managing the app's controllers.
   private lazy var tabCoordinator: TabCoordinator = {
      return TabCoordinator(categoryManager: categoryManager, trackManager: trackManager)
   }()
   
   /// The view controller assigned as the window's root view controller.
   private(set) lazy var rootViewController: UIViewController = {
      return tabCoordinator.rootViewController
   }()
   
   /// A manager for reading and writing data instances that are or need to be stored on disk.
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
      // Sets up and presents the window.
      window.rootViewController = rootViewController
      window.makeKeyAndVisible()
      
      tabCoordinator.start()
   }
   
   /// Persists all user-defined data used by the app.
   func persistAllData() {
      storageManager.persist(categoryManager)
      storageManager.persist(trackManager)
   }
}
