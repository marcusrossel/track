//
//  CategoriesCoordinator.swift
//  Track
//
//  Created by Marcus Rossel on 19.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Categories Coordinator

final class CategoriesCoordinator: NSObject, Coordinator {
   
   #warning("Hacky")
   private var asyncStorage: [String: Any] = [:]
   
   private var childCoordinators: [Coordinator] = []
   let categoryManager: Category.Manager
   
   let navigationController: UINavigationController
   
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

extension CategoriesCoordinator:
   CategoriesControllerDelegate, UIPopoverPresentationControllerDelegate
{
   
   func setupNavigationBar(for controller: CategoriesController) {
      controller.title = "Categories"
      navigationController.isNavigationBarHidden = false
      navigationController.navigationBar.prefersLargeTitles = false
   }
   
   func categoriesControllerDidRequestNewCategory(_ controller: CategoriesController) {
      let categoryCreationController = CategoryCreationController(
         categoryManager: categoryManager, delegate: self
      )
      navigationController.pushViewController(categoryCreationController, animated: true)
   }
   
   func categoriesController(
      _ controller: CategoriesController, didTapColorDotForCell cell: CategoriesTableViewCell
   ) {
      guard let category = categoryManager.uniqueCategory(with: cell.title) else {
         fatalError("Expected category manager to contain exactly one category for title.")
      }
      
      let colorPicker = ColorPicker(selection: cell.color)
      colorPicker.hide(.alpha)
      
      let colorPickerController = UIViewController()
      colorPickerController.view = colorPicker
      colorPickerController.preferredContentSize = CGSize(width: 250, height: 200)

      let referencePoint = UIView()
      referencePoint.frame = CGRect(origin: cell.colorDot.center, size: .zero)
      cell.addSubview(referencePoint)
      
      colorPickerController.modalPresentationStyle = .popover
      colorPickerController.popoverPresentationController?.delegate = self
      colorPickerController.popoverPresentationController?.sourceView = referencePoint
      
      navigationController.present(colorPickerController, animated: true, completion: nil)
      
      asyncStorage["colorPickerCompletion: () -> ()"] = {
         category.color = colorPicker.selection
         controller.tableView.reloadData()
      }
   }
   
   // Makes sure a popover is presented as such.
   func adaptivePresentationStyle(for controller: UIPresentationController)
   -> UIModalPresentationStyle {
      return .none
   }
   
   func popoverPresentationControllerDidDismissPopover(
      _ popoverPresentationController: UIPopoverPresentationController
   ) {
      (asyncStorage["colorPickerCompletion: () -> ()"] as? () -> ())?()
      asyncStorage["colorPickerCompletion: () -> ()"] = nil
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
