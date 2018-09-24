//
//  TimerTabCoordinator.swift
//  Track
//
//  Created by Marcus Rossel on 18.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

/// The coordinator managing everything inside the timer tab.
final class TimerTabCoordinator: NSObject, Coordinator {
   
   /// The navigation controller managing the coordinator's controllers.
   let navigationController = UINavigationController()
   
   /// A means of retaining a popover handler when in use.
   private var popoverHandler: PopoverHandler?
   
   /// A reference to the category manager that can be passed to any controllers in need of it.
   private let categoryManager: CategoryManager
   
   /// A reference to the track manager that can be passed to any controllers in need of it.
   private let trackManager: TrackManager
   
   #warning("Unfitting domain.")
   /// A means of retaining a timer controllers current track, when transitioning to a new one.
   private var trackInTransition: Track?
   
   init(categoryManager: CategoryManager, trackManager: TrackManager) {
      self.categoryManager = categoryManager
      self.trackManager = trackManager
   }
   
   /// Hands over control to the timer tab coordinator.
   /// If there is a track that is currently running, an appropriate timer controller will be shown.
   /// Otherwise a category selection controller is shown.
   func run() {
      let controller: UIViewController
      
      // Sets up the `controller` differently depending on whether there is a running track.
      if let runningTrack = trackManager.runningTrack {
         controller = TimerController(
            category: runningTrack.category,
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
   
   /// A category selection controller shows a navigation bar only if it is shown as stand-alone.
   func setupNavigationBar(for controller: CategorySelectionController) {
      /// Makes sure the controller is shown as stand-alone.
      guard navigationController.viewControllers.last === controller else { return }
      
      /// Shows a large navigation bar with the title "Track...".
      controller.navigationItem.title = "Track..."
      controller.navigationItem.largeTitleDisplayMode = .always
      navigationController.navigationBar.prefersLargeTitles = true
      navigationController.setNavigationBarHidden(false, animated: true)
   }
   
   /// The method called once a category was selected in the category selection controller.
   func categorySelectionController(
      _ controller: CategorySelectionController, didSelect category: Category
   ) {
      // Performs diffent actions depending on whether a timer controller is already being shown,
      // or the category selection controller was a stand-alone.
      if let timerController = navigationController.viewControllers.last as? TimerController {
         // Gets the track that was being tracked before the new selection.
         guard let previousTrack = trackInTransition else {
            fatalError("Internal inconsistency when changing category in timer controller.")
         }
         
         // Gets the track belonging to the selected category.
         let trackForCategory = trackManager.currentTrack(for: category)
         
         transferRunningState(from: previousTrack, to: trackForCategory)
         timerController.track = trackForCategory
         
         navigationController.dismiss(animated: true, completion: nil)
      } else {
         // Creates a new timer controller from the selected category.
         let timerController = TimerController(
            category: category,
            trackManager: trackManager,
            categoryManager: categoryManager,
            delegate: self
         )
         
         navigationController.setViewControllers([timerController], animated: true)
      }
   }
   
   /// Stops the `previous` track from running and transfers its previous running state to the
   /// `current` track.
   private func transferRunningState(from previous: Track, to current: Track) {
      let previousWasRunning = trackManager.isRunning(previous.category)
      trackManager.stopRunning()
      
      if previousWasRunning { trackManager.setRunning(current.category) }
   }
}

// MARK: - Timer Controller Delegate

extension TimerTabCoordinator: TimerControllerDelegate {
   
   private func contrastColor(for color: UIColor) -> UIColor {
      return (color.luminosity < 0.8) ? .white : .black
   }
   
   func setupNavigationBar(for controller: TimerController) {
      controller.navigationItem.title = controller.track.category.title
      controller.navigationItem.largeTitleDisplayMode = .always
      navigationController.setNavigationBarHidden(false, animated: true)
      navigationController.navigationBar.prefersLargeTitles = true
   }
   
   func timerController(_ timerController: TimerController, changedTrackTo track: Track) {
      let categoryColor = timerController.track.category.color
      navigationController.navigationBar.barTintColor = categoryColor
      navigationController.navigationBar.isTranslucent = false
   }
   
   func timerControllerDidStop(_ timerController: TimerController) {
      trackManager.stopRunning()
      
      let controller = CategorySelectionController(
         categoryManager: categoryManager, trackManager: trackManager, delegate: self
      )
      navigationController.setViewControllers([controller], animated: true)
   }
   
   func timerControllerDidSwitch(_ timerController: TimerController) {
      trackInTransition = timerController.track
      
      let categorySelectionController = CategorySelectionController(
         categoryManager: categoryManager, trackManager: trackManager, delegate: self
      )
      
      let tableView = categorySelectionController.tableView!
      let cellCount = tableView.numberOfRows(inSection: 0)
      
      let preferredSize = categorySelectionController.preferredContentSize
      let newHeight = CGFloat(min(6, cellCount)) * tableView.rowHeight
      categorySelectionController.preferredContentSize = CGSize(
         width: preferredSize.width, height: newHeight
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
