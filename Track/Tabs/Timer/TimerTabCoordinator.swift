//
//  TimerTabCoordinator.swift
//  Track
//
//  Created by Marcus Rossel on 18.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Timer Tab Coordinator

/// The coordinator managing everything inside the timer tab.
final class TimerTabCoordinator: NSObject, Coordinator {
   
   /// The navigation controller managing the coordinator's controllers.
   let navigationController = UINavigationController()
   
   /// A means of retaining a popover handler when in use.
   private var popoverHandler: PopoverHandler?
   
   #warning("Potential reference cylce.")
   /// A factory used for creating the controllers used in the timer tab.
   private var controllerFactory: TimerTabControllerFactory!
   
   /// A reference to the category manager that can be passed to any controllers in need of it.
   private let categoryManager: CategoryManager
   
   /// A reference to the track manager that can be passed to any controllers in need of it.
   private let trackManager: TrackManager
   
   /// A property for accessing the timer controller sitting at the top of the navigation stack, if
   /// that is the case.
   private var timerController: TimerController? {
      return navigationController.viewControllers.last as? TimerController
   }
   
   /// A property for accessing the selection controller sitting at the top of the navigation stack,
   /// if that is the case.
   private var categorySelectionController: CategorySelectionController? {
      return navigationController.viewControllers.last as? CategorySelectionController
   }
   
   #warning("Bad place to put this button.")
   private var timerEditButton: UIBarButtonItem!
   
   init(categoryManager: CategoryManager, trackManager: TrackManager) {
      // Phase 1.
      self.categoryManager = categoryManager
      self.trackManager = trackManager
      
      // Phase 2.
      super.init()
      
      // Phase 3.
      controllerFactory = TimerTabControllerFactory(user: self, categoryManager: categoryManager)
      categoryManager.addObserver(AnyCategoryManagerObserver(self))
      timerEditButton = UIBarButtonItem(
         image: nil, style: .plain, target: self, action: #selector(toggleTimerControllerEditing)
      )
   }
   
   /// Hands over control to the timer tab coordinator.
   /// If there is a category that is currently running, an appropriate timer controller will be
   /// shown. Otherwise a selection controller is shown.
   func run() {
      let controller: UIViewController
      
      // Assigns a differnt controller depending on whether there is a running track.
      if let runningTrack = trackManager.runningTrack {
         controller = controllerFactory.makeTimerController(for: runningTrack.category)
      } else {
         controller = controllerFactory.makeCategorySelectionController()
      }

      navigationController.pushViewController(controller, animated: true)
   }
}

// MARK: - Category Manager Observer

extension TimerTabCoordinator: CategoryManagerObserver {

   /// Stops the current timer controller if necessary.
   func categoryManager(_ categoryManager: CategoryManager, didRemoveCategory category: Category) {
      // Makes sure the currently shown view controller is a timer controller managing a track for
      // the given category.
      guard timerController?.category == category else { return }
      
      let selectionController = controllerFactory.makeCategorySelectionController()
      navigationController.setViewControllers([selectionController], animated: true)
   }
   
   /// Updates the timer controllers navigation bar if necessary.
   func categoryManager(
      _ categoryManager: CategoryManager, observedChangeInCategory category: Category
   ) {
      // Handles the case of the currently shown view controller being a timer controller managing a
      // track for the given category.
      if let timerController = timerController, timerController.category == category {
         // Pretends that the timer controller is tracking a new category, to cause all related
         // updates to happen.
         self.timerController(timerController, isTrackingCategory: category)
      }
      // Handles the case of the currently shown view controller being a selection controller.
      else if let selectionController = categorySelectionController {
         selectionController.tableView.reloadData()
      }
   }
   
   /// Updates a selection controllers categories if necessary.
   func categoryManagerDidChange(_ categoryManager: CategoryManager) {
      categorySelectionController?.categories = categoryManager.categories
   }
}

// MARK: - Timer Controller Data Source and Delegate

extension TimerTabCoordinator: TimerControllerDataSource, TimerControllerDelegate {
   
   /// Gets the current track for the given category from the track manger.
   func track(for category: Category) -> Track {
      return trackManager.currentTrack(for: category)
   }
   
   /// Gets the state of the given category from the track manger.
   func categoryIsRunning(_ category: Category) -> Bool {
      return trackManager.isRunning(category)
   }

   /// Sets up the navigation bar with a large display mode.
   func setupNavigationBar(for controller: TimerController) {
      controller.navigationItem.largeTitleDisplayMode = .always
      navigationController.setNavigationBarHidden(false, animated: true)
      navigationController.navigationBar.prefersLargeTitles = true
      
      adaptTimerEditButton(to: controller)
      controller.navigationItem.setRightBarButtonItems([timerEditButton], animated: true)
   }
   
   private func adaptTimerEditButton(to timerController: TimerController) {
      let imageLoader = ImageLoader(useDefaultSizes: false)
      let image: UIImage
      
      if timerController.isEditingDuration {
         image = imageLoader[button: .confirmEdit]
      } else {
         image = imageLoader[button: .editTime]
      }
      
      timerEditButton.image = image
         .resizedKeepingAspect(forSize: .square(of: 30))
         .withRenderingMode(.alwaysTemplate)
      timerEditButton.tintColor = .highlightColor(contrasting: timerController.category.color)
   }
   
   @objc private func toggleTimerControllerEditing() {
      guard let timerController = timerController else {
         fatalError("Expected to find a timer controller at the top of the navigation stack.")
      }
      
      if timerController.isEditingDuration {
         timerController.endDurationEditing()
      } else {
         timerController.beginDurationEditing()
      }
      
      adaptTimerEditButton(to: timerController)
   }
   
   /// Updates the navigation bar to match the given category.
   func timerController(_ timerController: TimerController, isTrackingCategory category: Category) {
      timerController.navigationItem.title = category.title
      navigationController.navigationBar.barTintColor = category.color
      navigationController.navigationBar.isTranslucent = false
      
      let textColor = UIColor.highlightColor(contrasting: category.color)
      navigationController.navigationBar.largeTitleTextAttributes = [.foregroundColor: textColor]
      adaptTimerEditButton(to: timerController)
   }
   
   func timerController(
      _ timerController: TimerController, needsUpdatedDuration duration: TimeInterval
   ) {
      trackManager.setDurationOfTrack(forCategory: timerController.category, to: duration)
   }
   
   /// Tells the track manager to set the given category as running.
   func timerController(
      _ timerController: TimerController, needsPlayForCategory category: Category
   ) {
      trackManager.setRunning(category)
   }
   
   /// Tells the track manager to stop the currently running category.
   func timerControllerNeedsPause(_ timerController: TimerController) {
      trackManager.stopRunning()
   }
   
   /// Stops the currently running category, and pushes a category selection controller.
   func timerControllerNeedsStop(_ timerController: TimerController) {
      trackManager.stopRunning()
      
      let selectionController = controllerFactory.makeCategorySelectionController()
      navigationController.setViewControllers([selectionController], animated: true)
   }
   
   /// Presents a category selection controller as a popover.
   func timerControllerNeedsSwitch(_ timerController: TimerController) {
      let selectionController = controllerFactory.makeCategorySelectionController(forPopover: true)
      
      popoverHandler = PopoverHandler(
         presentedController: selectionController, sourceView: timerController.switchButton
      )
      
      popoverHandler?.present(in: navigationController)
   }
}

// MARK: - Category Selection Controller Delegate

extension TimerTabCoordinator: CategorySelectionControllerDelegate {
   
   /// A category selection controller shows a navigation bar only if it is shown as stand-alone.
   func setupNavigationBar(for controller: CategorySelectionController) {
      /// Makes sure the controller is shown as stand-alone.
      guard categorySelectionController === controller else { return }
      
      /// Shows a large navigation bar with the title "Track...".
      controller.navigationItem.title = "Track..."
      controller.navigationItem.largeTitleDisplayMode = .always
      navigationController.navigationBar.prefersLargeTitles = true
      navigationController.setNavigationBarHidden(false, animated: true)
      navigationController.navigationBar.setColorsToDefault()
   }
   
   /// The method called once a category was selected in the category selection controller.
   func categorySelectionController(
      _ controller: CategorySelectionController, didSelectCategoryWithTitle title: String
   ) {
      guard let category = categoryManager.uniqueCategory(with: title) else {
         fatalError("Internal inconsistency when selecting category from selection controller.")
      }
      
      // Performs diffent actions depending on whether a timer controller is already being shown,
      // or the category selection controller was a stand-alone.
      guard let timerController = timerController else {
         // Creates a timer controller for the selected category.
         let timerController = controllerFactory.makeTimerController(for: category)
         navigationController.setViewControllers([timerController], animated: true)
         return
      }
      
      // Determines whether the previous category was running,
      let previousWasRunning = trackManager.runningTrack != nil
      
      // Stops the timer controller's running category if there was one, and transfers that state
      // to the new category.
      trackManager.stopRunning()
      if previousWasRunning { trackManager.setRunning(category) }
      
      timerController.category = category
      
      navigationController.dismiss(animated: true, completion: nil)
   }
}
