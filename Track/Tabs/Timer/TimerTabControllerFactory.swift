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
   typealias User = AnyObject &
      TimerControllerDataSource &
      TimerControllerDelegate &
      CategorySelectionControllerDelegate
   
   /// The instance using the factory.
   /// Using the factory from any other instance can cause crashes!
   private unowned var user: User
   
   /// The category manager used to initialize
   private let categoryManager: CategoryManager
   
   /// A cache property for created timer controllers, in order to reduce allocation overhead.
   private var cachedTimerController: TimerController?
   
   /// A cache property for created selection controllers, in order to reduce allocation overhead.
   private var cachedSelectionController: CategorySelectionController?
   
   init(user: User, categoryManager: CategoryManager) {
      self.user = user
      self.categoryManager = categoryManager
   }
   
   /// Returns a timer controller for the specified category.
   func makeTimerController(for category: Category) -> TimerController {
      // Creates a new timer controller if necessary.
      let controller = cachedTimerController ??
         TimerController(category: category, dataSource: user, delegate: user)

      // Either sets the controllers properties or the cache depending on whether the controller was
      // reused.
      if cachedTimerController != nil {
         controller.category = category
      } else {
         cachedTimerController = controller
      }
      
      return controller
   }
   
   /// Returns a category selection controller, adjusted for use in a popover if declared.
   func makeCategorySelectionController(forPopover: Bool = false) -> CategorySelectionController {
      // Creates a new selection controller if necessary.
      let controller = cachedSelectionController ??
         CategorySelectionController(categories: categoryManager.categories, delegate: user)
      
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
         cachedSelectionController = controller
      }
      
      return controller
   }
}
