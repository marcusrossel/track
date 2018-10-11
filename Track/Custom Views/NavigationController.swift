//
//  NavigationController.swift
//  Track
//
//  Created by Marcus Rossel on 01.10.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

/// A aubclass of `UINavigationController` that allows for observation.
final class NavigationController: UINavigationController {
   
   /// The container storing the instances observing the category.
   private var observers: [ObjectIdentifier: AnyNavigationControllerObserver] = [:]
   
   /// Creates a navigation controller.
   init() {
      // Phase 2.
      super.init(nibName: nil, bundle: nil)
      
      // Phase 3.
      delegate = self
   }
   
   // MARK: - Requirements
   
   /// Do not call this initializer! This view does not support storyboards or XIB.
   required init?(coder aDecoder: NSCoder) { fatalError("View doesn't support storyboard or XIB.") }
}

// MARK: - Navigation Controller Delegate

extension NavigationController: UINavigationControllerDelegate {
   
   /// Notifies observers that the given view controller will be shown.
   func navigationController(
      _ navigationController: UINavigationController,
      willShow viewController: UIViewController,
      animated: Bool
   ) {
      notifyObservers { $0.navigationController(self, willShow: viewController) }
   }
}

// MARK: - Observation

extension NavigationController {
   
   func addObserver(_ observer: NavigationControllerObserver) {
      observers[ObjectIdentifier(observer)] = AnyNavigationControllerObserver(observer)
   }

   func removeObserver(_ observer: NavigationControllerObserver) {
      observers[ObjectIdentifier(observer)] = nil
   }

   private func notifyObservers(with closure: (NavigationControllerObserver) -> ()) {
      for (id, typeErasedWrapper) in observers {
         if let observer = typeErasedWrapper.observer {
            closure(observer)
         } else {
            observers[id] = nil
         }
      }
   }
   
}

// MARK: - Navigation Controller Observer

protocol NavigationControllerObserver: AnyObject {
   
   func navigationController(
      _ navigationController: NavigationController, willShow controller: UIViewController
   )
}

/// A workaround for the missing ability of protocol existentials to conform to protocols.
final class AnyNavigationControllerObserver {
   private(set) weak var observer: NavigationControllerObserver?
   init(_ observer: NavigationControllerObserver) { self.observer = observer }
}
