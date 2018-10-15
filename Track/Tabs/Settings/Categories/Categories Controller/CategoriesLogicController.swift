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
   
   /// The category convertible instances being managed by the controller.
   private(set) var categoryContainers: [CategoryConvertible]
   
   /// Creates a categories logic controller.
   init(categories: [Category]) {
      self.categoryContainers = categories
   }
   
   /// Inserts a category prototype at the front of the category containers.
   /// The index of the new prototype is returned.
   func addPrototype() -> Int {
      let prototype = Category.Prototype(title: "", color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
      categoryContainers.insert(prototype, at: 0)
      
      return 0
   }
   
   /// Tries to turn a given category container into a category.
   /// This only has an effect if the given container is a prototype.
   func categorize(_ container: CategoryConvertible) -> (Category, Int)? {
      // Makes sure the given container is even part of the containers being managed.
      guard let containerIndex = categoryContainers.firstIndex(where: { $0 === container }) else {
         return nil
      }
      
      // Tries to create a category from a given prototype, and returns `false` if it's not
      // possible.
      guard
         container is Category.Prototype,
         let newCategory = Category(title: container.title, color: container.color)
      else { return nil }
      
      // Replaces the prototype with the new category.
      categoryContainers[containerIndex] = newCategory
      
      return (newCategory, containerIndex)
   }
   
   /// Removes a container at the given index.
   func removeContainer(at index: Int) -> CategoryConvertible {
      return categoryContainers.remove(at: index)
   }
   
   /// Moves a container at a given origin to a given destination.
   func moveContainer(at origin: Int, to destination: Int)
   -> (categoryOrigin: Int, categoryDestination: Int)? {
      // If the container in question is just a prototype, simply move it.
      guard categoryContainers[origin] is Category else {
         let container = categoryContainers.remove(at: origin)
         categoryContainers.insert(container, at: destination)
         return nil
      }
      
      // Gets the previous category index of the category, moves it, and gets the resulting index.
      
      let previousCategoryIndex = categoryIndex(forContainerIndex: origin)
      
      let container = categoryContainers.remove(at: origin)
      categoryContainers.insert(container, at: destination)
      
      let currentCategoryIndex = categoryIndex(forContainerIndex: destination)
      
      // If the category index of the container hasn't changed we're done.
      guard previousCategoryIndex != currentCategoryIndex else { return nil }
      
      return (previousCategoryIndex, currentCategoryIndex)
   }
   
   /// Maps the index of container, to the number of categories that have come before it in the
   /// category containers.
   private func categoryIndex(forContainerIndex containerIndex: Int) -> Int {
      return (0..<containerIndex).reduce(0) { result, index in
         if categoryContainers[index] is Category { return result + 1}
         return result
      }
   }
}
