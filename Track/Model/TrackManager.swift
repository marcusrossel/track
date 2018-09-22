//
//  TrackManager.swift
//  Track
//
//  Created by Marcus Rossel on 18.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Track Manager

final class TrackManager {
   
   private var idleTracks: Set<Track> = []
   private var running: (category: Category, startDate: Date)?
   
   var tracks: Set<Track> {
      guard let newRunning = updateRunning() else { return idleTracks }
      self.running = (category: newRunning.track.category, startDate: newRunning.startDate)
      
      return idleTracks.union([newRunning.track])
   }
   
   var runningTrack: Track? {
      guard let newRunning = updateRunning() else { return nil }
      self.running = (category: newRunning.track.category, startDate: newRunning.startDate)
      
      return newRunning.track
   }
   
   private func updateRunning() -> (track: Track, startDate: Date)? {
      guard let running = running else { return nil }
      let now = Date()
      
      let newTracks = TrackManager.tracks(
         for: running.category,
         from: running.startDate,
         until: now
      )
      
      let newRunningTrack = newTracks.last!
      let newIdles = newTracks.dropLast()
      let newStartDate = now.addingTimeInterval(-newRunningTrack.duration)
      
      idleTracks.formUnion(newIdles)
      
      return (track: newRunningTrack, startDate: newStartDate)
   }
   
   init() { }
   
   init?(tracks: Set<Track> = []) {
      guard tracksAreSafeToInsert(tracks) else { return nil }
      idleTracks = tracks
   }
   
   func isRunning(_ category: Category) -> Bool {
      return running?.category == category
   }
   
   @discardableResult
   func setRunning(_ category: Category) -> Track {
      // Handels the case of there already being a running category.
      if let runningTrack = runningTrack {
         // Handles the case of it being the category that should be set running.
         guard runningTrack.category != category else { return runningTrack }
         
         // Handles the case of it being a different category.
         idleTracks.insert(runningTrack)
         running = nil
      }
      
      let now = Date()
      let todayStamp = Track.timeStamp(for: now)
      let shouldRun: (Track) -> Bool = { $0.timeStamp == todayStamp && $0.category == category }
      
      // Handles the case of there already existing a track for the given category and with today's
      // time stamp in the idle tracks.
      if let trackToRun = idleTracks.first(where: shouldRun) {
         idleTracks.remove(trackToRun)
         
         let startDate = now.addingTimeInterval(-trackToRun.duration)
         running = (category: category, startDate: startDate)
         
         return trackToRun
      } else { // Handles the case of there not existing a track with the needed properties yet.
         running = (category: category, startDate: now)
         return Track(category: category, date: now)
      }
   }
   
   func stopRunning() {
      guard let newRunning = updateRunning() else { return }
      
      idleTracks.formUnion([newRunning.track])
      self.running = nil
   }
   
   private func tracksAreSafeToInsert(_ tracks: Set<Track>) -> Bool {
      if let running = running {
         return tracks.allSatisfy { track in
            guard track.category != running.category else { return false }
            
            let dateComponents = DateComponents(
               year: track.timeStamp.year,
               month: track.timeStamp.month,
               day: track.timeStamp.day
            )
            let dateForTrackTimeStamp = Track.calendar.date(from: dateComponents)!
            
            return dateForTrackTimeStamp < running.startDate
         }
      } else {
         return tracks.allSatisfy { track in
            idleTracks.allSatisfy { idleTrack in
               track.timeStamp != idleTrack.timeStamp || track.category != idleTrack.category
            }
         }
      }
   }
   
   func currentTrack(for category: Category) -> Track {
      let now = Date()
      let todayStamp = Track.timeStamp(for: now)
      let fittingTrack = tracks.first {
         $0.timeStamp == todayStamp && $0.category == category
      }
      
      return fittingTrack ?? Track(category: category, date: now)
   }
   
   static func tracks(for category: Category, from startDate: Date, until endDate: Date)
   -> [Track] {
      var tracks: [Track] = []
      var processedDate = startDate
      var trackEndDate = startDate
      
      while trackEndDate < endDate {
         let nextProcessedDay = Track.calendar.date(byAdding: .day, value: 1, to: processedDate)!
         let endOfProcessedDay = Track.calendar.startOfDay(for: nextProcessedDay)
         
         trackEndDate = min(endDate, endOfProcessedDay)
         
         let duration = trackEndDate.timeIntervalSince(processedDate)
         let newTrack = Track(category: category, date: processedDate, duration: duration)!
         
         tracks.append(newTrack)
         processedDate = trackEndDate
      }
      
      return tracks
   }
}

// MARK: - Category Manager Observer

extension TrackManager: CategoryManagerObserver {
   
   func categoryManager(_ categoryManager: CategoryManager, didRemoveCategory category: Category) {
      idleTracks = idleTracks.filter { track in track.category != category }
      if running?.category == category { running = nil }
   }
}
