//
//  TimerTabControllerFactory.swift
//  Track
//
//  Created by Marcus Rossel on 25.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

/// A type able to create the controllers used in the timer tab.
final class TimerTabControllerFactory {
   
   /// A type able to use the factory.
   typealias Owner = AnyObject &
      TimerControllerDataSource &
      TimerControllerDelegate &
      CategorySelectionControllerDelegate
   
   /// The instance using and owning the factory.
   /// Using the factory from any other instance can cause crashes!
   private unowned var owner: Owner
   
   /// The category manager used to initialize
   private let categoryManager: CategoryManager
   
   /// A cache property for created timer controllers, in order to reduce allocation overhead.
   private var cachedTimerController: TimerController?
   
   /// A cache property for created selection controllers, in order to reduce allocation overhead.
   private var cachedSelectionController: CategorySelectionController?
   
   /// The navigation bar button used to toggle duration edit mode for timer controllers.
   lazy var timerEditButton: UIBarButtonItem = {
      return UIBarButtonItem(
         image: nil, style: .plain, target: self, action: #selector(timerEditButtonAction)
      )
   }()
   
   /// The closure called when the timer edit button is pressed.
   private var editButtonClosure: () -> ()
   
   /// The action method called when the timer edit button is pressed.
   @objc private func timerEditButtonAction() {
      editButtonClosure()
   }
   
   /// Creates a timer tab controller factory.
   init(owner: Owner, categoryManager: CategoryManager, editButtonClosure: @escaping () -> ()) {
      self.owner = owner
      self.categoryManager = categoryManager
      self.editButtonClosure = editButtonClosure
      
      categoryManager.addObserver(self)
   }
   
   /// Returns a timer controller for the specified category.
   func makeTimerController(for category: Category) -> TimerController {
      // Either updates a reused controller or creates a new one and caches it.
      if let reusedController = cachedTimerController {
         // Updates the reused controller.
         reusedController.category = category
         return reusedController
      } else {
         // Sets up a new controller.
         let newController = TimerController(category: category, dataSource: owner, delegate: owner)
         newController.navigationItem.largeTitleDisplayMode = .always
         newController.navigationItem.setRightBarButtonItems([timerEditButton], animated: true)
         
         // Caches and returns the new controller.
         cachedTimerController = newController
         return newController
      }
   }
   
   /// Returns a category selection controller, adjusted for use in a popover if declared.
   func makeCategorySelectionController(forPopover: Bool = false) -> CategorySelectionController {
      // Creates a new selection controller if necessary.
      let controller = cachedSelectionController ??
         CategorySelectionController(categories: categoryManager.categories, delegate: owner)
      
      // Sets the controller's preferred content size if it's meant to be used in a popover.
      if forPopover {
         let cellCount = controller.tableView.numberOfRows(inSection: 0)
         let defaultPreferredSize = controller.preferredContentSize
         let newHeight = CGFloat(min(6, cellCount)) * controller.tableView.rowHeight
         let preferredSize = CGSize(width: defaultPreferredSize.width, height: newHeight)
         controller.preferredContentSize = preferredSize
      }
      
      // Either sets the controllers properties or the cache depending on whether the controller was
      // reused.
      if cachedSelectionController != nil {
         controller.categories = categoryManager.categories
      } else {
         controller.navigationItem.title = "Track..."
         controller.navigationItem.largeTitleDisplayMode = .always
         cachedSelectionController = controller
      }
      
      return controller
   }
}

// MARK: - Category Manager Observer

extension TimerTabControllerFactory: CategoryManagerObserver {
   
   // Removes cached controllers, if they contain the removed category.
   func categoryManager(_ categoryManager: CategoryManager, didRemoveCategory category: Category) {
      if cachedTimerController?.category == category { cachedTimerController = nil }
      
      if cachedSelectionController?.categories.contains(category) == true {
         cachedSelectionController = nil
      }
   }
}
