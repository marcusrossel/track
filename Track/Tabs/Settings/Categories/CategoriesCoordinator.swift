//
//  CategoriesCoordinator.swift
//  Track
//
//  Created by Marcus Rossel on 19.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Categories Coordinator

/// The coordinator to handle everything inside the "Categories" settings-area.
final class CategoriesCoordinator: Coordinator {
   
   /// The navigation controller managing the coordinator's controllers.
   let navigationController: UINavigationController
   
   /// A handler for popover-presentation of controllers.
   /// This variable will only be populated when a popover is currently being shown,
   private var popoverHandler: PopoverHandler?
   
   /// A reference to the category manager that can be passed to any controllers in need of it.
   private let categoryManager: CategoryManager
   
   /// Creates a categories coordinator with given controllers and managers.
   init(
      categoryManager: CategoryManager = CategoryManager(),
      navigationController: UINavigationController = UINavigationController()
   ) {
      self.categoryManager = categoryManager
      self.navigationController = navigationController
   }
   
   /// Causes controll to be handed over to the coordinator.
   /// This causes a categories controller to be shown.
   func run() {
      let categoriesController = CategoriesController(
         categoryManager: categoryManager, delegate: self
      )
      
      navigationController.pushViewController(categoriesController, animated: true)
   }
}

// MARK: - Categories Controller Delegate

extension CategoriesCoordinator: CategoriesControllerDelegate {
   
   /// A categories controller shows a non-large title navigation bar.
   func setupNavigationBar(for controller: CategoriesController) {
      controller.navigationItem.title = "Categories"
      controller.navigationItem.largeTitleDisplayMode = .never
      navigationController.setNavigationBarHidden(false, animated: true)
   }
   
   /// Handles a new category request, by showing a category creation controller.
   func categoriesControllerDidRequestNewCategory(_ controller: CategoriesController) {
      let categoryCreationController = CategoryCreationController(
         categoryManager: categoryManager, delegate: self
      )
      navigationController.present(categoryCreationController, animated: true, completion: nil)
   }
   
   /// Handles a category controller's color dot being tapped, by creating a color picker popover
   /// and changing the associated category's color according to the selection.
   func categoriesController(
      _ controller: CategoriesController,
      didTapColorDotForCell cell: EditableCategoryCell
   ) {
      // Gets the category associated with the tapped color dot's cell.
      guard let category = categoryManager.uniqueCategory(with: cell.title) else {
         fatalError("Expected category manager to contain exactly one category for title.")
      }

      // Sets up a color picker with the color dot's color.
      let colorPicker = ColorPicker(selection: cell.color)
      
      // Sets up the popover handler for a color picker controller.
      popoverHandler = PopoverHandler(
         presentedController: makeController(for: colorPicker),
         sourceView: cell.colorDot
      ) {
         category.color = colorPicker.selection
         
         // Reloads the affected cell.
         guard let cellPath = controller.tableView.indexPath(for: cell) else {
            fatalError("Expected cell to be part of table view.")
         }
         controller.tableView.reloadRows(at: [cellPath], with: .fade)
         
         self.popoverHandler = nil
      }
      
      // Presents the color picker controller as a popover.
      popoverHandler?.present(in: navigationController)
   }
   
   /// Creates a view controller for a given color picker.
   private func makeController(for colorPicker: ColorPicker) -> UIViewController {
      colorPicker.hide(.alpha)
      
      let colorPickerController = UIViewController()
      colorPickerController.view = colorPicker
      colorPickerController.preferredContentSize = CGSize(width: 250, height: 200)
      
      return colorPickerController
   }
}

// MARK: - Category Creation Controller Delegate

extension CategoriesCoordinator: CategoryCreationControllerDelegate {
   
   #warning("Delete me.")
   func setupNavigationBar(for controller: CategoryCreationController) { }
   
   func categoryCreationControllerDidCancel(
      _ categoryCreationController: CategoryCreationController
   ) {
      navigationController.dismiss(animated: true, completion: nil)
   }
   
   /// Saves the category associated with a category creation controller.
   /// This also causes the controller to be dismissed.
   func categoryCreationController(
      _ categoryCreationController: CategoryCreationController,
      didRequestSaveForCategory category: Category
   ) {
      _ = categoryManager.insert(category, atIndex: 0)
      navigationController.dismiss(animated: true)
   }
}
