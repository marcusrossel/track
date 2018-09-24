//
//  Observation.swift
//  Track
//
//  Created by Marcus Rossel on 22.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import Foundation

// MARK: - Observer Type

protocol ObserverType: AnyObject { }

// MARK: - Broadcaster

protocol Broadcaster: AnyObject {
   
   associatedtype Observer: ObserverType
   
   var observers: [ObjectIdentifier: Weak<Observer>] { get set }
   
   func addObserver(_ observer: Observer)
   func removeObserver(_ observer: Observer)
}

extension Broadcaster {
   
   func addObserver(_ observer: Observer) {
      observers[ObjectIdentifier(observer)] = Weak(observer)
   }
   
   func removeObserver(_ observer: Observer) {
      observers[ObjectIdentifier(observer)] = nil
   }
   
   func notifyObservers(with closure: (Observer) -> ()) {
      for (id, weakObserver) in observers {
         if let observer = weakObserver.object {
            closure(observer)
         } else {
            // Removes those weak observers whose object has already been deinitialized.
            observers[id] = nil
         }
      }
   }
}
