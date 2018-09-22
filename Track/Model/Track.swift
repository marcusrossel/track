//
//  Track.swift
//  Track
//
//  Created by Marcus Rossel on 17.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Track

struct Track {
   
   let category: Category
   let timeStamp: TimeStamp
   let duration: TimeInterval
   
   init?(category: Category, date: Date = Date(), duration: TimeInterval) {
      self.category = category
      
      timeStamp = Track.timeStamp(for: date)
      
      guard Track.isValid(duration: duration) else { return nil }
      self.duration = duration
   }
   
   init(category: Category, date: Date = Date()) {
      self.init(category: category, date: date, duration: 0)!
   }
   
   private static func isValid(duration: TimeInterval) -> Bool {
      return duration >= 0 && duration <= maximumDuration
   }
}

extension Track: Equatable, Hashable {
   
   static func ==(lhs: Track, rhs: Track) -> Bool {
      return
         lhs.category == rhs.category &&
            lhs.timeStamp == rhs.timeStamp &&
            lhs.duration == rhs.duration
   }
   
   func hash(into hasher: inout Hasher) {
      hasher.combine(category)
      hasher.combine(timeStamp.year)
      hasher.combine(timeStamp.month)
      hasher.combine(timeStamp.day)
      hasher.combine(duration)
   }
}

// MARK: - Time Properties

extension Track {
   
   typealias TimeStamp = (year: Int, month: Int, day: Int)
   
   static var calendar: Calendar {
      return Calendar(identifier: .gregorian)
   }
   
   static var maximumDuration: TimeInterval {
      let now = Date()
      let tomorrow = Track.calendar.date(byAdding: .day, value: 1, to: now)!
      return tomorrow.timeIntervalSince(now)
   }
   
   static func timeStamp(for date: Date) -> TimeStamp {
      let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
      
      guard
         let year = dateComponents.year,
         let month = dateComponents.month,
         let day = dateComponents.day
      else {
         fatalError("Expected to be able to access requested date components.")
      }
      
      return (year, month, day)
   }
   
   static func date(for timeStamp: TimeStamp) -> Date {
      let dateComponents = DateComponents(
         year: timeStamp.year, month: timeStamp.month, day: timeStamp.day
      )
      
      return  Track.calendar.date(from: dateComponents)!
   }
}
