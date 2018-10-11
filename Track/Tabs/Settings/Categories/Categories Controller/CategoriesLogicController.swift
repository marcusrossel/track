//
//  CategoriesLogicController.swift
//  Track
//
//  Created by Marcus Rossel on 09.10.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Categories Logic Controller

/// A type handeling a categories controller's business logic.
final class CategoriesLogicController {
   
   /// The categories controller using this logic controller instance.
   private unowned var owner: CategoriesController
   
   /// A delegate providing functionality external to this controller.
   private weak var delegate: CategoriesLogicControllerDelegate?
   
   /// The categories and prototypes being managed by the controller.
   private(set) var categoryContainers: [CategoryContainer]
   
   /// Creates a categories logic controller.
   init(
      owner: CategoriesController,
      categoryContainers: [CategoryContainer],
      delegate: CategoriesLogicControllerDelegate? = nil
   ) {
      self.owner = owner
      self.categoryContainers = categoryContainers
      self.delegate = delegate
   }
   
   /// Inserts a category prototype at the front of the category containers.
   /// The index of the new prototype is returned.
   func addPrototype() -> Int {
      let prototype = Category.Prototype()
      categoryContainers.insert(prototype, at: 0)
      
      return 0
   }
   
   /// Removes a prototype at the given index, if it actually refers to a prototype.
   /// The return value indicated whether removal was successful.
   func removePrototype(at index: Int) -> Bool {
      // Makes sure the index refers to a prototype.
      guard categoryContainers[index] is Category.Prototype else { return false }
      
      categoryContainers.remove(at: index)
      return true
   }
   
   /// Removes a category at the given index, if it actually refers to a category.
   /// The return value indicated whether removal was successful.
   func removeCategory(at index: Int) -> Bool {
      // Makes sure the index refers to a category.
      guard categoryContainers[index] is Category else { return false }
      
      // Removes the category and propagates the event to the delegate.
      categoryContainers.remove(at: index)
      delegate?.categoriesController(owner, didRemoveCategoryAtIndex: index)
      
      return true
   }
   
   /// Moves a container at a given origin to a given destination.
   func moveContainer(at origin: Int, to destination: Int) {
      // If the container in question is just a prototype, simply move it.
      guard categoryContainers[origin] is Category else {
         let container = categoryContainers.remove(at: origin)
         categoryContainers.insert(container, at: destination)
         return
      }
      
      // Gets the previous category index of the category, moves it, and gets the resulting index.
      
      let previousCategoryIndex = categoryIndex(forContainerIndex: origin)
      
      let container = categoryContainers.remove(at: origin)
      categoryContainers.insert(container, at: destination)
      
      let currentCategoryIndex = categoryIndex(forContainerIndex: destination)
      
      // If the category index of the container hasn't changed we're done.
      guard previousCategoryIndex != currentCategoryIndex else { return }
      
      // Propagates the event to the delegate.
      delegate?.categoriesController(
         owner, didMoveCategoryAtIndex: previousCategoryIndex, toIndex: currentCategoryIndex
      )
   }
   
   /// Maps the index of container, to the number of categories that have come before it in the
   /// category containers.
   private func categoryIndex(forContainerIndex containerIndex: Int) -> Int {
      return (0..<containerIndex).reduce(0) { result, index in
         result + (categoryContainers[index] is Category ? 1 : 0)
      }
   }
}

// MARK: - Categories Logic Controller Delegate

/// A delegate providing functionality external to a categories logic controller.
protocol CategoriesLogicControllerDelegate: AnyObject {
   
   func categoriesController(
      _ categoriesController: CategoriesController, didRemoveCategoryAtIndex index: Int
   )
   
   func categoriesController(
      _ categoriesController: CategoriesController,
      didMoveCategoryAtIndex source: Int,
      toIndex destination: Int
   )
}
