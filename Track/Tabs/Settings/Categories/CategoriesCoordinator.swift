//
//  CategoriesCoordinator.swift
//  Track
//
//  Created by Marcus Rossel on 19.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Categories Coordinator

final class CategoriesCoordinator: Coordinator {
   
   #warning("Hacky")
   private var asyncStorage: [String: Any] = [:]
   
   private var childCoordinators: [Coordinator] = []
   let navigationController: UINavigationController
   private var popoverHandler: PopoverHandler?
   
   let categoryManager: Category.Manager
   
   var categoriesController: CategoriesController {
      for child in navigationController.children.reversed() {
         if let controller = child as? CategoriesController {
            return controller
         }
      }
      fatalError("Expected there to be a `CategoriesController`.")
   }
   
   init(
      categoryManager: Category.Manager = Category.Manager(),
      navigationController: UINavigationController = UINavigationController()
   ) {
      self.categoryManager = categoryManager
      self.navigationController = navigationController
   }
   
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
      controller.title = "Categories"
      navigationController.isNavigationBarHidden = false
      navigationController.navigationBar.prefersLargeTitles = false
   }
   
   /// Handles a new category request, by showing a category creation controller.
   func categoriesControllerDidRequestNewCategory(_ controller: CategoriesController) {
      let categoryCreationController = CategoryCreationController(
         categoryManager: categoryManager, delegate: self
      )
      navigationController.pushViewController(categoryCreationController, animated: true)
   }
   
   /// Handles a category controller's color dot being tapped, by creating a color picker popover
   /// and changing the associated category's color according to the selection.
   func categoriesController(
      _ controller: CategoriesController,
      didTapColorDotForCell cell: CategoriesTableViewCell
   ) {
      // Gets the category associated with the tapped color dot's cell.
      guard let category = categoryManager.uniqueCategory(with: cell.title) else {
         fatalError("Expected category manager to contain exactly one category for title.")
      }
      
      // Sets up a color picker with the color dot's color.
      let colorPicker = ColorPicker(selection: cell.color)
      
      // Sets up the popover handler a color picker controller.
      popoverHandler = PopoverHandler(
         presentedController: makeController(for: colorPicker),
         sourceView: cell.colorDot
      ) {
         category.color = colorPicker.selection
         controller.tableView.reloadData()
         self.popoverHandler = nil
      }
      
      // Presents the color picker controller as a popover.
      popoverHandler?.present(in: navigationController)
   }
   
   /// Creates a view controller for a color picker given a certain selection.
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
   
   @objc private func saveCategoryForCategoryCreationController() {
      guard
         let controller = asyncStorage["categoryCreationController: CategoryCreationController"]
         as? CategoryCreationController
      else {
         fatalError("Internal inconsistency with async storage.")
      }
      
      guard let category = controller.category else {
         fatalError("Internal inconsistency with save button for category creation controller.")
      }
      
      guard categoryManager.insert(category, atIndex: 0) else {
         fatalError("Internal inconsistency between category manager and creation controller.")
      }
      
      navigationController.popViewController(animated: true)
   }
   
   func categoryCreationControllerCanSaveCategory(
      _ categoryCreationController: CategoryCreationController
   ) {
      navigationController.navigationItem.rightBarButtonItem?.isEnabled = true
   }
   
   func categoryCreationControllerCanNotSaveCategory(
      _ categoryCreationController: CategoryCreationController
   ) {
      navigationController.navigationItem.rightBarButtonItem?.isEnabled = false
   }
   
   func setupNavigationBar(for controller: CategoryCreationController) {
      controller.title = "Create Category"
      navigationController.isNavigationBarHidden = false
      navigationController.navigationBar.prefersLargeTitles = false
      
      navigationController.navigationItem.rightBarButtonItem = UIBarButtonItem(
         barButtonSystemItem: .save,
         target: self,
         action: #selector(saveCategoryForCategoryCreationController)
      )
   }
}
