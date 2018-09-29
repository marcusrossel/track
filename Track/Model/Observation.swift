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
   
   #warning("Potential reference cylce.")
   var observers: [ObjectIdentifier: Observer] { get set }
   
   func addObserver(_ observer: Observer)
   func removeObserver(_ observer: Observer)
}

extension Broadcaster {
   
   func addObserver(_ observer: Observer) {
      observers[ObjectIdentifier(observer)] = observer
   }
   
   func removeObserver(_ observer: Observer) {
      observers[ObjectIdentifier(observer)] = nil
   }
   
   func notifyObservers(with closure: (Observer) -> ()) {
      observers.values.forEach(closure)
   }
}
