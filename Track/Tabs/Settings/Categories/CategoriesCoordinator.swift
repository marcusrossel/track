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
      navigationController: NavigationController = NavigationController()
   ) {
      self.categoryManager = categoryManager
      self.navigationController = navigationController
      
      navigationController.addObserver(self)
      navigationController.navigationBar.prefersLargeTitles = false
   }
   
   /// Causes controll to be handed over to the coordinator.
   /// This causes a categories controller to be shown.
   func run() {
      let categoriesController = CategoriesController(
         categories: categoryManager.categories, delegate: self
      )
      categoriesController.navigationItem.title = "Categories"
      
      navigationController.pushViewController(categoriesController, animated: true)
   }
}

// MARK: - Navigation Controller Observer

extension CategoriesCoordinator: NavigationControllerObserver {
   
   /// Makes sure that the navigation bar is behaving correctly, before a categories controller is
   /// shown.
   func navigationController(
      _ navigationController: NavigationController, willShow controller: UIViewController
   ) {
      // Only acts if the controller to be shown is a settings root controller.
      guard controller is CategoriesController else { return }
      
      // Makes sure the navigation bar is still shown and setup correctly.
      navigationController.setNavigationBarHidden(false, animated: true)
      navigationController.navigationBar.prefersLargeTitles = false
      navigationController.navigationBar.tintAdjustmentMode = .normal
   }
}

// MARK: - Categories Controller Delegate

extension CategoriesCoordinator: CategoriesControllerDelegate {
   
   func categoriesController(
      _ categoriesController: CategoriesController, didRemoveCategoryAtIndex index: Int
   ) {
      categoryManager.remove(atIndex: index)
   }

   func categoriesController(
      _ controller: CategoriesController,
      didMoveCategoryAtIndex origin: Int,
      toIndex destination: Int
   ) {
      categoryManager.move(categoryAtIndex: origin, to: destination)
   }
   
   func categoriesController(
      _ categoriesController: CategoriesController,
      didAddCategory newCategory: Category,
      atIndex index: Int
   ) {
      guard categoryManager.insert(newCategory, atIndex: index) else {
         fatalError(
            "Internal inconsistency between categories logic controller and category manager."
         )
      }
   }
   
   func categoriesControllerDidStartEditingCategoryTitle(
      _ categoriesController: CategoriesController
   ) {
      navigationController.navigationBar.isUserInteractionEnabled = false
      navigationController.navigationBar.tintColor = #colorLiteral(red: 0.5960784314, green: 0.5960784314, blue: 0.6156862745, alpha: 1)
   }
   
   func categoriesControllerDidEndEditingCategoryTitle(
      _ categoriesController: CategoriesController
   ) {
      navigationController.navigationBar.isUserInteractionEnabled = true
      navigationController.navigationBar.tintColor = nil
   }
   
   /// Handles a category controller's color dot being tapped, by creating a color picker popover
   /// and changing the associated category's color according to the selection.
   func categoriesController(
      _ controller: CategoriesController,
      needsColorChangeForContainerAtIndexPath containerIndexPath: IndexPath
   ) {
      // Gets the category container associated with the given container index path.
      let container = controller.categoryContainers[containerIndexPath.row]
      
      // Gets the category container associated with the given container index path.
      guard
         let cell = controller.tableView.cellForRow(at: containerIndexPath) as? CategoryCell
      else {
         fatalError("Internal inconsistency in categories controller.")
      }

      // Sets up a color picker with the color dot's color.
      let colorPicker = ColorPicker(selection: cell.color)
      
      // Sets up the popover handler for a color picker controller.
      popoverHandler = PopoverHandler(
         presentedController: makeController(for: colorPicker),
         sourceView: cell.colorDot
      ) {
         container.color = colorPicker.selection
         controller.tableView.reloadRows(at: [containerIndexPath], with: .fade)
         
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
