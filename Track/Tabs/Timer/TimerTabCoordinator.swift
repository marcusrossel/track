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
   let navigationController: UINavigationController
   
   /// A means of retaining a popover handler when in use.
   private var popoverHandler: PopoverHandler?
   
   /// A factory used for creating the controllers used in the timer tab.
   private var controllerFactory: TimerTabControllerFactory!
   
   /// A reference to the category manager that can be passed to any controllers in need of it.
   private let categoryManager: CategoryManager
   
   /// A reference to the track manager that can be passed to any controllers in need of it.
   private let trackManager: TrackManager
   
   /// A property for accessing the timer controller sitting at the top of the navigation stack, if
   /// that is the case.
   private var timerController: TimerController? {
      return navigationController.topViewController as? TimerController
   }
   
   /// A property for accessing the selection controller sitting at the top of the navigation stack,
   /// if that is the case.
   private var categorySelectionController: CategorySelectionController? {
      return navigationController.topViewController as? CategorySelectionController
   }
   
   /// Creates a timer tab coordinator.
   init(categoryManager: CategoryManager, trackManager: TrackManager) {
      // Phase 1.
      self.categoryManager = categoryManager
      self.trackManager = trackManager
      
      let navigationController = NavigationController()
      self.navigationController = navigationController
      
      // Phase 2.
      super.init()
      
      // Phase 3.
      controllerFactory = TimerTabControllerFactory(
         owner: self,
         categoryManager: categoryManager,
         editButtonClosure: toggleTimerControllerEditing
      )
      
      categoryManager.addObserver(self)
      navigationController.addObserver(self)
   }
   
   /// The method called when the timer edit button is pressed.
   private func toggleTimerControllerEditing() {
      // Makes sure a timer controller is being shown.
      guard let timerController = timerController else {
         fatalError("Internal inconsistency in timer controller.")
      }
      
      // Toggles the duration edit state.
      if timerController.isEditingDuration {
         timerController.endDurationEditing()
      } else {
         timerController.beginDurationEditing()
      }
      
      // Updates the timer edit button to match the timer controller's new state.
      updateTimerEditButton(for: timerController)
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
   
   /// A method that should be called by any object managing a timer tab coordinator, when the
   /// coordinator's content is about to disappear from view.
   func willDisappear() {
      UIApplication.shared.statusBarStyle = .default
   }
}

// MARK: - Category Manager Observer

extension TimerTabCoordinator: CategoryManagerObserver {

   /// Removes all tracks associated with the given category and stops the current timer controller
   /// if necessary.
   func categoryManager(_ categoryManager: CategoryManager, didRemoveCategory category: Category) {
      // Stops the currently shown view controller if it is a timer controller managing a track for
      // the given category.
      if let timerController = timerController, timerController.category == category {
         timerControllerNeedsStop(timerController)
      }
      
      // Removes all of the tracks associated with the category.
      trackManager.removeAllTracks(for: category)
   }
   
   /// Updates the timer controllers navigation bar if necessary.
   func categoryManager(
      _ categoryManager: CategoryManager, observedChangeInCategory category: Category
   ) {
      // Makes sure the currently shown view controller being a timer controller managing a track
      // for the given category.
      guard let timerController = timerController, timerController.category == category else {
         return
      }
      
      // Pretends that the timer controller is tracking a new category, to cause all related updates
      // to occur.
      self.timerController(timerController, switchedToCategory: category)
   }
   
   /// Updates a selection controllers categories if necessary.
   func categoryManagerDidChange(_ categoryManager: CategoryManager) {
      // This code doesn't handle the case of the selection controller being shown as a popover,
      // which doesn't matter as no changes to categories can occur while being "trapped" in a
      // popover.
      categorySelectionController?.categories = categoryManager.categories
      categorySelectionController?.tableView.reloadData()
   }
}

// MARK: - Navigation Controller Observer

extension TimerTabCoordinator: NavigationControllerObserver {
   
   /// Makes sure that the navigation bar is behaving correctly, before any controller is shown.
   func navigationController(
      _ navigationController: NavigationController, willShow controller: UIViewController
   ) {
      // Sets up the navigation bar differently for timer controllers and category selection
      // controllers.
      if let timerController = controller as? TimerController {
         setupNavigationBar(for: timerController)
      } else if let selectionController = controller as? CategorySelectionController {
         setupNavigationBar(for: selectionController)
      }
   }
   
   /// Sets up navigation bar properties which are not tied to a controller's navigation item.
   private func setupNavigationBar(for timerController: TimerController) {
      navigationController.setNavigationBarHidden(false, animated: true)
      navigationController.navigationBar.prefersLargeTitles = true
      updateNavigationBar(for: timerController)
   }
   
   /// Sets navigation bar properties that need to be updated when a timer controller's properties
   /// change, but the shown controller remains a timer controller.
   private func updateNavigationBar(for timerController: TimerController) {
      let category = timerController.category
      
      // Sets the title text.
      timerController.navigationItem.title = category.title
      
      // Sets the background color.
      navigationController.navigationBar.barTintColor = category.color
      navigationController.navigationBar.isTranslucent = false
      
      // Sets the title text color.
      let textColor: UIColor = category.color.isLight ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
      navigationController.navigationBar.largeTitleTextAttributes = [.foregroundColor: textColor]
      
      // Sets the status bar color.
      UIApplication.shared.statusBarStyle = category.color.isLight ? .default : .lightContent
      
      // Sets the timer edit button's image and color.
      updateTimerEditButton(for: timerController)
   }
   
   /// Sets the timer edit button's image and color to match the state of a given timer controller.
   private func updateTimerEditButton(for timerController: TimerController) {
      let imageLoader = ImageLoader(useDefaultSizes: false)
      let timerEditButton = controllerFactory.timerEditButton
      
      // Gets the timer edit button's image.
      let type: ImageLoader.Button = timerController.isEditingDuration ? .confirmEdit : .editTime
      let image = imageLoader[button: type]
         .resizedKeepingAspect(forSize: .square(of: 30))
         .withRenderingMode(.alwaysTemplate)
      
      // Sets the timer edit button's image and color.
      timerEditButton.image = image
      timerEditButton.tintColor = timerController.category.color.isLight ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
   }
   
   /// Sets up navigation bar properties which are not tied to a controller's navigation item.
   func setupNavigationBar(for selectionController: CategorySelectionController) {
      // A category selection controller shows a navigation bar only if it is shown as stand-alone.
      guard categorySelectionController === selectionController else { return }
      
      navigationController.navigationBar.prefersLargeTitles = true
      navigationController.setNavigationBarHidden(false, animated: true)
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
   
   /// Updates the navigation bar to match the given category.
   func timerController(_ timerController: TimerController, switchedToCategory category: Category) {
      updateNavigationBar(for: timerController)
   }
   
   /// Tells the track manager to set the given category's track to the given duration.
   func timerController(
      _ timerController: TimerController,
      updatedDuration duration: TimeInterval,
      forCategory category: Category
   ) {
      // Tries to set the duration.
      let success = trackManager.setDurationOfTrack(forCategory: category, to: duration)
      
      // Makes sure the track manager was able to set the new duration.
      guard success else {
         fatalError("Internal inconsistency between timer controller and track manager.")
      }
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
   
   /// Tells the track manager to stop the currently running category, and pushes a category
   /// selection controller.
   func timerControllerNeedsStop(_ timerController: TimerController) {
      trackManager.stopRunning()
      
      // Sets navigation and status bar related properties back to default.
      UIApplication.shared.statusBarStyle = .default
      navigationController.navigationBar.setColorsToDefault()
      
      let selectionController = controllerFactory.makeCategorySelectionController()
      navigationController.setViewControllers([selectionController], animated: true)
   }
   
   /// Presents a category selection controller as a popover.
   func timerControllerNeedsSwitch(_ timerController: TimerController) {
      let selectionController = controllerFactory.makeCategorySelectionController(forPopover: true)
      
      // Creates a popover handler, anchoring the popover in the center of the timer controller's
      // switch button.
      popoverHandler = PopoverHandler(
         presentedController: selectionController, sourceView: timerController.switchButton
      )
      
      popoverHandler?.present(in: navigationController)
   }
}

// MARK: - Category Selection Controller Delegate

extension TimerTabCoordinator: CategorySelectionControllerDelegate {
   
   /// The method called, once a category was selected in the category selection controller.
   func categorySelectionController(
      _ controller: CategorySelectionController, didSelectCategory category: Category
   ) {
      // Shortcuts if there is no timer controller being shown.
      guard let timerController = timerController else {
         // Handles the case of the category selection controller being a stand-alone, by creating a
         // timer controller for the selected category.
         let timerController = controllerFactory.makeTimerController(for: category)
         navigationController.setViewControllers([timerController], animated: true)
         return
      }
      
      // Determines whether the previous category was running,
      let previousWasRunning = trackManager.runningTrack != nil
      
      // Stops the timer controller's running category if there was one, and transfers that state
      // to the new category.
      if previousWasRunning {
         trackManager.stopRunning()
         trackManager.setRunning(category)
      }
      
      // Updates the timer controller's category to the given one.
      timerController.category = category
      
      // Dismisses the category selection controller popover.
      navigationController.dismiss(animated: true, completion: nil)
   }
}
