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
