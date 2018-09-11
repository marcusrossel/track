//
//  Track+Manager.swift
//  Track
//
//  Created by Marcus Rossel on 08.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Track

final class Track: Codable {
   
   static let calendar = Calendar(identifier: .gregorian)
   
   let category: Category
   private var start: Date
   private var end: Date?
   
   init(category: Category, day: Date = Date(), interval: TimeInterval = 0) {
      self.category = category
      self.start = day
      self.interval = interval
   }
   
   var day: Date { return Track.calendar.startOfDay(for: start) }
   
   /// The amount of time that has been tracked for the given category on the track's `day`.
   /// This value updates continuously when the track is currently tracking.
   ///
   /// Let `t` be the time interval that has elapsed from the beginning of the track's `day` until
   /// now. Setting the interval to a value `x` will actually set it to: `min(max(0, x), t, 24h)`.
   var interval: TimeInterval {
      get { return (end ?? Date()).timeIntervalSince(start) }
      set {
         let elapsedTimeInDay = Date().timeIntervalSince(day)
         
         let nonNegative = max(0, newValue)
         let intervalToSet = min(nonNegative, elapsedTimeInDay, dayInterval)
         
         start = day
         end = start.addingTimeInterval(intervalToSet)
      }
   }
   
   var isTracking: Bool { return end == nil }

   func track() {
      guard let fixedEnd = end else { return }
      let fixedInterval = fixedEnd.timeIntervalSince(start)
      
      start = Date().addingTimeInterval(-fixedInterval)
      end = nil
   }
   
   func stop() -> Set<Track>? {
      // Handles the case of the track not even running.
      guard end == nil else { return nil }
      
      let now = Date()
      let nextDay = Track.calendar.date(byAdding: DateComponents(day: 1), to: day)!
      
      // Handles the case of the current date being on the same day as the track's `day`.
      guard now >= nextDay else {
         end = now
         return nil
      }
      
      // Handles the case of the current date being on a later day than the track's `day`.
      end = nextDay
      return makeTracks(from: nextDay, until: now)
   }
   
   private func makeTracks(from beginning: Date, until end: Date) -> Set<Track> {
      var tracks: Set<Track> = []
      var processedDate = beginning
      
      while processedDate < end {
         let trackInterval = min(end.timeIntervalSince(processedDate), dayInterval)
         let track = Track(category: category, day: day, interval: trackInterval)
         
         tracks.insert(track)
         processedDate = processedDate.addingTimeInterval(trackInterval)
      }
      
      return tracks
   }
   
   private var dayInterval: TimeInterval {
      let nextDay = Track.calendar.date(byAdding: DateComponents(day: 1), to: day)!
      return nextDay.timeIntervalSince(day)
   }
}

extension Track: Equatable, Hashable {
   
   static func ==(lhs: Track, rhs: Track) -> Bool {
      return lhs.category == rhs.category && lhs.start == rhs.start
   }
   
   func hash(into hasher: inout Hasher) {
      hasher.combine(category)
      hasher.combine(start)
   }
}

extension Track {
   
   final class Manager {
      
      private(set) var tracks: Set<Track> = []
      
      var runningCategory: Category? {
         return (tracks.first { $0.isTracking })?.category
      }
      
      init?(tracks: Set<Track> = []) {
         guard tracksAreSafeToInsert(tracks) else { return nil }
         self.tracks = tracks
      }
      
      private func tracksAreSafeToInsert(_ tracks: Set<Track>) -> Bool {
         var newTracks = self.tracks
         
         let newTracksForDay: (Date) -> [Track] = { day in
            return newTracks.filter { track in
               Track.calendar.startOfDay(for: day) == Track.calendar.startOfDay(for: track.day)
            }
         }
         
         for track in newTracks {
            guard !newTracksForDay(track.day).contains(where: { $0.category == track.category })
            else { return false }
            
            newTracks.insert(track)
         }
         
         return true
      }

      func todaysTrack(for category: Category) -> Track? {
         let isToday = Calendar(identifier: .gregorian).isDateInToday(_:)
         let todaysTracks = tracks.filter { isToday($0.day) }
         
         return todaysTracks.first { $0.category == category }
      }
      
      func addTracks(_ newTracks: Set<Track>) -> Bool {
         guard tracksAreSafeToInsert(newTracks) else { return false }
         
         tracks.formUnion(newTracks)
         return true
      }
      
      @discardableResult
      func createTrack(for category: Category) -> Track? {
         guard todaysTrack(for: category) == nil else { return nil }
         
         let track = Track(category: category)
         
         tracks.insert(track)
         return track
         
      }
   }
}
