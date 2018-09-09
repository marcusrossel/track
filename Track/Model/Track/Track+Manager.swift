//
//  Track+Manager.swift
//  Track
//
//  Created by Marcus Rossel on 08.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

#warning("Dummy code.")

import UIKit

final class Track: Codable {
   
   private let category: Category
   private let day: Date 
   private(set) var interval: TimeInterval

   init(category: Category, day: Date = Date(), interval: TimeInterval = TimeInterval()) {
      self.category = category
      self.day = day
      self.interval = interval
   }
}

extension Track {
   
   final class Manager {
      
      private(set) var tracks: [Track] = []
      private(set) var runningCategory: Category? = Category(title: "Category Title 5", color: .white)
      
      func todaysTrack(for category: Category) -> Track? {
         let isToday = Calendar(identifier: .gregorian).isDateInToday(_:)
         let todaysTracks = tracks.filter { isToday($0.day) }
         
         return todaysTracks.first { $0.category == category }
      }
      
      @discardableResult
      func createTrack(for category: Category) -> Track? {
         guard todaysTrack(for: category) == nil else { return nil }
         
         let today = Calendar(identifier: .gregorian).startOfDay(for: Date())
         let track = Track(category: category, day: today, interval: 0)
         
         tracks.append(track)
         return track
         
      }
   }
}
