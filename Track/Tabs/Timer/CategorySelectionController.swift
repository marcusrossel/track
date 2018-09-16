//
//  CategorySelectionController.swift
//  Track
//
//  Created by Marcus Rossel on 11.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Category Selection Controller Delegate

protocol CategorySelectionControllerDelegate {
   
   func categorySelectionController(
      _ controller: CategorySelectionController, didSelect category: Category
   )
   
   func setupNavigationBar(for controller: CategorySelectionController)
}

extension CategorySelectionControllerDelegate {
   
   func setupNavigationBar(for controller: CategorySelectionController) { }
}

// MARK: - Category Selection Controller

final class CategorySelectionController: UITableViewController {

   var coordinator: CategorySelectionControllerDelegate?
   private let categoryManager: Category.Manager
   private let trackManager: Track.Manager
   
   init(
      categoryManager: Category.Manager,
      trackManager: Track.Manager,
      delegate: CategorySelectionControllerDelegate? = nil
   ) {
      // Phase 1.
      self.categoryManager = categoryManager
      self.trackManager = trackManager
      coordinator = delegate
      
      // Phase 2.
      super.init(style: .plain)
      
      // Phase 3.
      tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
      tableView.rowHeight = .defaultHeight
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      coordinator?.setupNavigationBar(for: self)
      
      // The table view should always reload its data on appearance, as to capture changes that
      // might have been made to categories externally.
      tableView.reloadData()
   }
   
   // MARK: - Requirements
   
   /// Do not call this initializer! This view does not support storyboards or XIB.
   required init?(coder aDecoder: NSCoder) { fatalError("View doesn't support storyboard or XIB.") }
}

extension CategorySelectionController {
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return categoryManager.categories.count
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
   -> UITableViewCell {
      #warning("Efficiency: Not reusing cells.")
      let cell = CategoryCell(style: .default, reuseIdentifier: CategoryCell.identifier)
      let category = categoryManager.categories[indexPath.row]
      
      cell.title = category.title
      cell.color = category.color
      
      return cell
   }
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      guard let cell = tableView.cellForRow(at: indexPath) as? CategoryCell else {
         fatalError("Expected table view to contain requested cell.")
      }
      
      guard let category = categoryManager.uniqueCategory(with: cell.title) else {
         fatalError("Expected to find unique category with given title.")
      }
      
      coordinator?.categorySelectionController(self, didSelect: category)
   }
}
