//
//  TimerTabCoordinator.swift
//  Track
//
//  Created by Marcus Rossel on 18.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

final class TimerTabCoordinator: Coordinator {
   
   private var hasRunBefore = false
   
   let navigationController = UINavigationController()
   private var popoverHandler: PopoverHandler?
   
   private let categoryManager: Category.Manager
   private let trackManager: Track.Manager
   
   init(categoryManager: Category.Manager, trackManager: Track.Manager) {
      self.categoryManager = categoryManager
      self.trackManager = trackManager
      navigationController.isNavigationBarHidden = true
   }
   
   func run() {
      defer { hasRunBefore = true }
      guard !hasRunBefore else { return }
      
      let controller: UIViewController
      
      if let category = trackManager.runningCategory {
         controller = TimerController(delegate: self, category: category)
      } else {
         controller = CategorySelectionController(categories: categoryManager.categories)
      }

      navigationController.pushViewController(controller, animated: true)
   }
}

extension TimerTabCoordinator: TimerControllerDelegate {
   
   func timerControllerDidStop(_ timerController: TimerController) {
      print("Stop")
   }
   
   func timerControllerDidSwitch(_ timerController: TimerController) {
      let categorySelectionController = CategorySelectionController(
         categories: categoryManager.categories
      )
      
      popoverHandler = PopoverHandler(
         presentedController: categorySelectionController,
         sourceView: timerController.switchButton
      ) {
         self.popoverHandler = nil
      }
      
      popoverHandler?.present(in: navigationController)
   }
}
