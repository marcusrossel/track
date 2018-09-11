//
//  TimerTabCoordinator.swift
//  Track
//
//  Created by Marcus Rossel on 18.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

final class TimerTabCoordinator: NSObject, Coordinator {
   
   private var hasRunBefore = false
   
   let navigationController = UINavigationController()
   private var popoverHandler: PopoverHandler?
   
   private var selectedCategory: Category?
   private let categoryManager: Category.Manager
   private let trackManager: Track.Manager
   
   init(categoryManager: Category.Manager, trackManager: Track.Manager) {
      self.categoryManager = categoryManager
      self.trackManager = trackManager
      navigationController.setNavigationBarHidden(true, animated: true)
   }
   
   func run() {
      defer { hasRunBefore = true }
      guard !hasRunBefore else { return }
      
      let controller: UIViewController
      
      if let categoryID = trackManager.trackingCategoryID {
         guard let category = categoryManager.uniqueCategory(with: categoryID) else {
            fatalError("Expected to find category with given ID.")
         }
            
         controller = TimerController(
            categoryID: category.id,
            trackManager: trackManager,
            categoryManager: categoryManager,
            delegate: self
         )
      } else {
         controller = CategorySelectionController(
            categoryManager: categoryManager, trackManager: trackManager, delegate: self
         )
      }

      navigationController.pushViewController(controller, animated: true)
   }
}

// MARK: - Category Selection Controller Delegate

extension TimerTabCoordinator: CategorySelectionControllerDelegate {
   
   func setupNavigationBar(for controller: CategorySelectionController) {
      controller.navigationItem.title = "Track..."
      controller.navigationItem.largeTitleDisplayMode = .always
      navigationController.navigationBar.prefersLargeTitles = true
      navigationController.setNavigationBarHidden(false, animated: true)
   }
   
   func categorySelectionController(
      _ controller: CategorySelectionController, didSelect category: Category
   ) {
      if let timerController = navigationController.viewControllers[0] as? TimerController {
         let trackForCategory =
            trackManager.todaysTrack(for: category.id) ??
            trackManager.createTrack(for: category.id)!
         
         // Expecting the previously running track to already be stopped, if there was one!
         trackForCategory.track()
         timerController.track = trackForCategory
         
         navigationController.dismiss(animated: true, completion: nil)
      } else {
         let controller = TimerController(
            categoryID: category.id,
            trackManager: trackManager,
            categoryManager: categoryManager,
            delegate: self
         )
         
         navigationController.setViewControllers([controller], animated: true)
      }
   }
}

// MARK: - Timer Controller Delegate

extension TimerTabCoordinator: TimerControllerDelegate {
   
   func setupNavigationBar(for controller: TimerController) {
      navigationController.isNavigationBarHidden = true
   }
   
   func timerControllerDidStop(_ timerController: TimerController) {
      let _ = timerController.track.stop()
      
      let controller = CategorySelectionController(
         categoryManager: categoryManager, trackManager: trackManager, delegate: self
      )
      navigationController.setViewControllers([controller], animated: true)
   }
   
   func timerControllerDidSwitch(_ timerController: TimerController) {
      let categorySelectionController = CategorySelectionController(
         categoryManager: categoryManager, trackManager: trackManager, delegate: self
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
