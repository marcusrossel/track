//
//  Entities.swift
//  Track
//
//  Created by Marcus Rossel on 17.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Track Entity

extension Track: Persistable {
   
   struct Entity: EntityType, Hashable {
      
      let categoryTitle: String
      let year: Int
      let month: Int
      let day: Int
      let duration: TimeInterval
      
      init(modelledType track: Track) {
         categoryTitle = track.category.title
         (year, month, day) = track.timeStamp
         duration = track.duration
      }
   }
}

// MARK: - Track Manager Entity

extension TrackManager: Persistable {
   
   struct Entity: EntityType {
      
      let trackEntities: Set<Track.Entity>
      let running: (categoryTitle: String, startDate: Date)?
      
      enum CodingKeys: CodingKey {
         case trackEntities
         case runningCategoryTitle
         case runningStartDate
      }
      
      func encode(to encoder: Encoder) throws {
         var container = encoder.container(keyedBy: CodingKeys.self)
         
         try container.encode(trackEntities, forKey: .trackEntities)
         try container.encode(running?.categoryTitle, forKey: .runningCategoryTitle)
         try container.encode(running?.startDate, forKey: .runningStartDate)
      }
      
      init(from decoder: Decoder) throws {
         let container = try decoder.container(keyedBy: CodingKeys.self)
         
         trackEntities = try container.decode(Set<Track.Entity>.self, forKey: .trackEntities)
         
         if let runningCategoryTitle = try container.decode(
            String?.self, forKey: .runningCategoryTitle
         ) {
            let runningStartDate = try container.decode(Date?.self, forKey: .runningStartDate)
            running = (categoryTitle: runningCategoryTitle, startDate: runningStartDate!)
         } else {
            running = nil
         }
      }
      
      init(modelledType trackManager: TrackManager) {
         trackEntities = Set(trackManager.tracks.map(Track.Entity.init(modelledType:)))
         
         if let runningTrack = trackManager.runningTrack {
            let startDate = Date().addingTimeInterval(-runningTrack.duration)
            let categoryTitle = runningTrack.category.title
            
            running = (categoryTitle: categoryTitle, startDate: startDate)
         } else {
            running = nil
         }
      }
   }
}
