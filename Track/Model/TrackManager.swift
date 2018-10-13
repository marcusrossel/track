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
   
   private(set) var idleTracks: Set<Track> = []
   
   private var running: (category: Category, startDate: Date)?
   
   /// A container keeping track of which categories have been updated on a specific day.
   /// This is used as an indicator to determine which categories need a "full update", and which
   /// only require an update to their running track, when calling `updateRunning`.
   /// The `updated.day` needs to be kept track of, as every category's update status should be
   /// invalidated when a new day begins.
   private var updated: (day: Date, categories: Set<Category>) = (Date(), [])
   
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
      
      // If the `updated` list refers to an outdated date, invalidate all categories' update status.
      if !Track.calendar.isDate(updated.day, inSameDayAs: now) { updated = (now, []) }
      
      // Shortcuts if the category has already been updated today.
      // In this case only a new running track needs to be created.
      guard !updated.categories.contains(running.category) else {
         let updatedDuration = now.timeIntervalSince(running.startDate)
         let updatedTrack = Track(category: running.category, date: now, duration: updatedDuration)!
         return (track: updatedTrack, startDate: running.startDate)
      }
      
      // Marks the category as updated for the current day.
      updated.categories.insert(running.category)
      
      // Creates all of the tracks that are needed to cover the time interval from the running start
      // date until now.
      let newTracks = TrackManager.tracks(
         for: running.category,
         from: running.startDate,
         until: now
      )
      
      // Splits the new tracks into those that are in the past and the one that is running.
      let newRunningTrack = newTracks.last!
      let newIdles = newTracks.dropLast()
      
      // The past tracks are now idle and therefore added to the `idleTracks`.
      idleTracks.formUnion(newIdles)
      
      // The running track is used to calculate the new running start date and is returned.
      let newStartDate = now.addingTimeInterval(-newRunningTrack.duration)
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
            return self.track(track, liesBefore: running.startDate)
         }
      } else {
         return tracks.allSatisfy { track in
            idleTracks.allSatisfy { idleTrack in
               track.timeStamp != idleTrack.timeStamp || track.category != idleTrack.category
            }
         }
      }
   }
   
   private func track(_ track: Track, liesBefore deadline: Date) -> Bool {
      let dateComponents = DateComponents(
         year: track.timeStamp.year,
         month: track.timeStamp.month,
         day: track.timeStamp.day
      )
      
      let dateForTrackTimeStamp = Track.calendar.date(from: dateComponents)!
      let dateForDeadline = Track.calendar.startOfDay(for: deadline)
      
      return dateForTrackTimeStamp < dateForDeadline
   }
   
   func currentTrack(for category: Category) -> Track {
      let now = Date()
      let todayStamp = Track.timeStamp(for: now)
      let fittingTrack = tracks.first {
         $0.timeStamp == todayStamp && $0.category == category
      }
      
      return fittingTrack ?? Track(category: category, date: now)
   }
   
   #warning("Currently only works on idle tracks.")
   @discardableResult
   func setDurationOfTrack(
      forCategory category: Category,
      onDate date: Date = Date(),
      to duration: TimeInterval
   ) -> Bool {
      guard duration >= 0 && duration <= Track.maximumDuration else { return false }
      
      let dateStamp = Track.timeStamp(for: date)
      let trackPredicate: (Track) -> Bool = { track in
         track.timeStamp == dateStamp && track.category == category
      }
      let newTrack = Track(category: category, date: date, duration: duration)!
      
      if let fittingTrack = tracks.first(where: trackPredicate) {
         idleTracks.remove(fittingTrack)
      }
      
      idleTracks.insert(newTrack)
      return true
   }
   
   @discardableResult
   func removeAllTracks(for category: Category) -> [Track] {
      // Removes all of the idle tracks of the given category and collects them.
      let removedIdles: [Track] = idleTracks.compactMap { idleTrack in
         // Guards for tracks of the given category.
         guard idleTrack.category == category else { return nil }
         
         // Removes the track.
         return idleTracks.remove(idleTrack)
      }
      
      // Completes if there is no running track, or it's not of the given category.
      guard let runningTrack = runningTrack, runningTrack.category == category else {
         return removedIdles
      }
      
      // Removes the running track and returns it with the removed idles.
      running = nil
      return removedIdles
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
      self.idleTracks = self.idleTracks.filter { track in track.category != category }
      if self.running?.category == category { self.running = nil }
   }
}
