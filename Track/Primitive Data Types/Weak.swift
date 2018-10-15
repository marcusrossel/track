//
//  Weak.swift
//  Track
//
//  Created by Marcus Rossel on 22.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

final class Weak<Object> where Object: AnyObject {
   
   private(set) weak var object: Object?
   
   init(_ object: Object) {
      self.object = object
   }
}

extension Weak: Equatable, Hashable where Object: Hashable {
   
   static func == (lhs: Weak<Object>, rhs: Weak<Object>) -> Bool {
      return lhs.object == rhs.object
   }
   
   func hash(into hasher: inout Hasher) {
      hasher.combine(object.hashValue)
   }
}
