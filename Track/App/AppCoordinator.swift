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
   
   /// A manager for accessing and writing to persistent data.
   private let persistenceManager = PersistenceManager()
   
   /// A manager for handeling the collection of existing categories.
   /// The manager is loaded from disk on app launch, or created anew if none was persisted before.
   private lazy var categoryManager: Category.Manager = loadCategoryManager()
   
   /// A manager for handeling the collection of existing tracks.
   /// The manager is loaded from disk on app launch, or created anew if none was persisted before.
   private lazy var trackManager: Track.Manager = loadTrackManager()
   
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
}

// MARK: - Persistence

extension AppCoordinator {
   
   /// Creates a category manager from the data stored on disk.
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
   
   /// Creates a track manager from the data stored on disk.
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
