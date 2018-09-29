//
//  StorageManager.swift
//  Track
//
//  Created by Marcus Rossel on 22.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

final class StorageManager {
   
   private let persistenceManager: PersistenceManager
   private var categoryManagerCache: (manager: CategoryManager, isCurrent: Bool)?
   private var trackManagerCache: (manager: TrackManager, isCurrent: Bool)?

   init(persistenceManager: PersistenceManager = PersistenceManager()) {
      self.persistenceManager = persistenceManager
   }
   
   /// Creates a category manager from the data stored on disk.
   func loadCategoryManager() -> CategoryManager {
      // Uses the cached manager if it exists and is current.
      if let (cachedManager, isCurrent) = categoryManagerCache, isCurrent { return cachedManager }
      
      let categoryManager: CategoryManager
      defer { categoryManagerCache = (manager: categoryManager, isCurrent: true) }
      
      do {
         let manager = try persistenceManager.read(.categoryManager, as: CategoryManager.self)
         categoryManager = manager ?? CategoryManager()
      } catch {
         fatalError("Persistence manager was unable to read categories.")
      }
      
      return categoryManager
   }
   
   /// Creates a track manager from the data stored on disk.
   func loadTrackManager() -> TrackManager {
      // Uses the cached manager if it exists and is current.
      if let (cachedManager, isCurrent) = trackManagerCache, isCurrent { return cachedManager }
      
      guard let managerEntity = loadTrackManagerEntity() else { return TrackManager() }
      
      let categoryManager = loadCategoryManager()
      let idleTracks = self.tracks(for: managerEntity.idleTrackEntities)
      
      guard let running = managerEntity.running else {
         let trackManager = TrackManager(tracks: idleTracks)!
         categoryManager.addObserver(AnyCategoryManagerObserver(trackManager))
         return trackManager
      }
      
      let runningCategory = categoryManager.uniqueCategory(with: running.categoryTitle)!
      let tracksFromRunning = TrackManager.tracks(
         for: runningCategory,
         from: running.startDate,
         until: Date()
      )
      
      let allTracks = idleTracks.union(tracksFromRunning)
      let trackManager = TrackManager(tracks: allTracks)!
      trackManager.setRunning(runningCategory)
      categoryManager.addObserver(AnyCategoryManagerObserver(trackManager))
      
      return trackManager
   }
   
   private func loadTrackManagerEntity() -> TrackManager.Entity? {
      do {
         return try persistenceManager.read(.trackManager, asEntityFor: TrackManager.self)
      } catch {
         fatalError("Persistence manager was unable to read tracks.")
      }
   }
   
   private func tracks(for trackEntities: Set<Track.Entity>) -> Set<Track> {
      let categoryManager = loadCategoryManager()
      
      let tracks: [Track] = trackEntities.map { entity in
         let category = categoryManager.uniqueCategory(with: entity.categoryTitle)!
         let dateForStamp = Track.date(for: (entity.year, entity.month, entity.day))
         
         return Track(category: category, date: dateForStamp, duration: entity.duration)!
      }
      
      return Set(tracks)
   }
   
   /// Persists all data that needs to be persisted by the app.
   func persist<T>(_ value: T) {
      do {
         if let categoryManager = value as? CategoryManager {
            try persistenceManager.write(.categoryManager, value: categoryManager)
            categoryManagerCache?.isCurrent = false
         } else if let trackManager = value as? TrackManager {
            try persistenceManager.write(.trackManager, asEntityFor: trackManager)
            trackManagerCache?.isCurrent = false
         }
      } catch {
         fatalError("Attempt to persist data failed.")
      }
   }
}
