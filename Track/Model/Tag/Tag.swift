//
//  Tag.swift
//  Track
//
//  Created by Marcus Rossel on 17.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import Foundation

struct Tag: Codable {
   
   typealias ID = UUID
   
   var id: ID
   var title: String
   
   init(title: String, id: ID = ID()) {
      self.title = title
      self.id = id
   }
}

extension Tag: Equatable {
   
   static func ==(lhs: Tag, rhs: Tag) -> Bool {
      return lhs.id == rhs.id
   }
}
