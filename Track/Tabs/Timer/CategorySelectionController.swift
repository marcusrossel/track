//
//  CategorySelectionController.swift
//  Track
//
//  Created by Marcus Rossel on 11.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Category Selection Controller

/// A controller displaying a list of categories from which one can be chosen.
final class CategorySelectionController: UITableViewController {

   /// A delegate providing functionality, external to the category selection controller.
   var delegate: CategorySelectionControllerDelegate?
   
   /// The categories being shown by the controller.
   var categories: [Category] {
      didSet { tableView.reloadData() }
   }
   
   /// Creates a category selection controller.
   init(categories: [Category], delegate: CategorySelectionControllerDelegate? = nil) {
      // Phase 1.
      self.categories = categories
      self.delegate = delegate
      
      // Phase 2.
      super.init(style: .plain)
      
      // Phase 3.
      tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
      tableView.rowHeight = .defaultHeight
   }
   
   // MARK: - Requirements
   
   /// Do not call this initializer! This view does not support storyboards or XIB.
   required init?(coder aDecoder: NSCoder) { fatalError("View doesn't support storyboard or XIB.") }
}

// MARK: - Table View Data Source and Delegate

extension CategorySelectionController {
   
   /// A table view has as many rows as categories.
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return categories.count
   }
   
   /// Sets up each cell from the category at the same index.
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
   -> UITableViewCell {
      // Dequeues the cell.
      guard
         let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.identifier, for: indexPath
         ) as? CategoryCell
      else {
         fatalError("Dequeued unexpected type of table view cell.")
      }
      
      // Sets up the cell.
      let category = categories[indexPath.row]
      cell.title = category.title
      cell.color = category.color
      
      return cell
   }
   
   // Propagates the selection of a category to the delegate.
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      // Gets the cell.
      guard let cell = tableView.cellForRow(at: indexPath) as? CategoryCell else {
         fatalError("Expected table view to contain requested cell.")
      }
      
      // Gets the category
      let hasTitle: (Category) -> Bool = { $0.title == cell.title }
      guard let category = categories.first(where: hasTitle) else {
         fatalError("Internal inconsistency in category selection controller.")
      }
      
      // Propagates the event to the delegate.
      delegate?.categorySelectionController(self, didSelectCategory: category)
   }
}

// MARK: - Category Selection Controller Delegate

/// A delegate providing functionality external to a category selection controller.
protocol CategorySelectionControllerDelegate {
   
   func categorySelectionController(
      _ controller: CategorySelectionController, didSelectCategory category: Category
   )
}
