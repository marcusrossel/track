//
//  TimerTabCoordinator.swift
//  Track
//
//  Created by Marcus Rossel on 18.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

final class TimerTabCoordinator: NSObject, Coordinator {
   
   private var hasRunBefore = false
   
   let navigationController = UINavigationController()
   private var popoverHandler: PopoverHandler?
   
   private var selectedCategory: Category?
   private let categoryManager: Category.Manager
   private let trackManager: Track.Manager
   
   init(categoryManager: Category.Manager, trackManager: Track.Manager) {
      self.categoryManager = categoryManager
      self.trackManager = trackManager
      navigationController.isNavigationBarHidden = true
   }
   
   func run() {
      defer { hasRunBefore = true }
      guard !hasRunBefore else { return }
      
      let controller: UIViewController
      
      if let category = trackManager.runningCategory {
         controller = TimerController(
            category: category, trackManager: trackManager, delegate: self
         )
      } else {
         controller = makeCategorySelectionController()
      }

      navigationController.pushViewController(controller, animated: true)
   }
}

// MARK: - Category Selection Controller

extension TimerTabCoordinator: UITableViewDataSource, UITableViewDelegate {
   
   private func makeCategorySelectionController() -> UIViewController {
      let categorySelectionController = UITableViewController(style: .plain)
      let tableView = categorySelectionController.tableView
      
      tableView?.dataSource = self
      tableView?.delegate = self
      tableView?.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
      tableView?.rowHeight = .defaultHeight
      
      return categorySelectionController
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return categoryManager.categories.count - (selectedCategory != nil ? 1 : 0)
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      guard
         let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.identifier, for: indexPath
         ) as? CategoryCell
      else { fatalError("Dequeued unexpected type of table view cell.") }
      
      var category = categoryManager.categories[indexPath.row]
      
      if let selected = selectedCategory,
         let indexOfSelected = categoryManager.categories.firstIndex(of: selected),
         indexOfSelected >= indexPath.row {
         category = categoryManager.categories[indexOfSelected + 1]
      }
      
      cell.title = category.title
      cell.color = category.color
      
      return cell
   }
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      #warning("Manifest timer state in track before switching to selection controller.")
      
      guard let cell = tableView.cellForRow(at: indexPath) as? CategoryCell else {
         fatalError("Expected table view to contain requested cell.")
      }
      
      guard let category = categoryManager.uniqueCategory(with: cell.title) else {
         fatalError("Expected to find unique category with given title.")
      }
      
      change(to: category)
   }
   
   private func change(to category: Category) {
      if let timerController = navigationController.viewControllers[0] as? TimerController {
         timerController.category = category
         navigationController.dismiss(animated: true, completion: nil)
      } else {
         let controller = TimerController(
            category: category, trackManager: trackManager, delegate: self
         )
         
         navigationController.setViewControllers([controller], animated: true)
      }
   }
}

extension TimerTabCoordinator: TimerControllerDelegate {
   
   func timerControllerDidStop(_ timerController: TimerController) {
      #warning("Manifest timer state in track before switching to selection controller.")
      
      let controller = makeCategorySelectionController()
      
      controller.title = "Category to track..."
      navigationController.isNavigationBarHidden = false
      navigationController.navigationBar.prefersLargeTitles = false
      
      navigationController.setViewControllers([controller], animated: true)
   }
   
   func timerControllerDidSwitch(_ timerController: TimerController) {
      popoverHandler = PopoverHandler(
         presentedController: makeCategorySelectionController(),
         sourceView: timerController.switchButton
      ) {
         self.popoverHandler = nil
      }
      
      popoverHandler?.present(in: navigationController)
   }
}
