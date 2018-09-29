//
//  CategorySelectionController.swift
//  Track
//
//  Created by Marcus Rossel on 11.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Category Selection Controller

final class CategorySelectionController: UITableViewController {

   var delegate: CategorySelectionControllerDelegate?
   
   var categories: [Category] {
      didSet { tableView.reloadData() }
   }
   
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
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      delegate?.setupNavigationBar(for: self)
   }
   
   // MARK: - Requirements
   
   /// Do not call this initializer! This view does not support storyboards or XIB.
   required init?(coder aDecoder: NSCoder) { fatalError("View doesn't support storyboard or XIB.") }
}

extension CategorySelectionController {
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return categories.count
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
   -> UITableViewCell {
      guard
         let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.identifier, for: indexPath
         ) as? CategoryCell
      else {
         fatalError("Dequeued unexpected type of table view cell.")
      }
      
      let category = categories[indexPath.row]
      
      cell.title = category.title
      cell.color = category.color
      
      return cell
   }
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      guard let cell = tableView.cellForRow(at: indexPath) as? CategoryCell else {
         fatalError("Expected table view to contain requested cell.")
      }
      
      delegate?.categorySelectionController(self, didSelectCategoryWithTitle: cell.title)
   }
}

// MARK: - Category Selection Controller Delegate

/// A delegate providing functionality external to a category selection controller.
protocol CategorySelectionControllerDelegate {
   
   func categorySelectionController(
      _ controller: CategorySelectionController, didSelectCategoryWithTitle title: String
   )
   
   func setupNavigationBar(for controller: CategorySelectionController)
}

/// Default implementations making the delegate methods optional.
extension CategorySelectionControllerDelegate {
   
//   func categorySelectionController(
//      _ controller: CategorySelectionController, didSelectCategoryWithTitle title: String
//   ) { }
//   
//   func setupNavigationBar(for controller: CategorySelectionController) { }
}
