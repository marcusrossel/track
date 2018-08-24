//
//  CategoriesController.swift
//  Track
//
//  Created by Marcus Rossel on 16.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Categoties Controller Delegate

protocol CategoriesControllerDelegate {
   
   func categoriesController(
      _ controller: CategoriesController, didTapColorDotForCell cell: CategoriesTableViewCell
   )
   
   func categoriesControllerDidRequestNewCategory(_ controller: CategoriesController)
   
   func setupNavigationBar(for controller: CategoriesController)
}

extension CategoriesControllerDelegate {
   
   func setupNavigationBar(for controller: CategoriesController) { }
}

// MARK: - Categoties Controller

final class CategoriesController: UITableViewController {

   private let coordinator: CategoriesControllerDelegate
   private let categoryManager: Category.Manager
   
   init(categoryManager: Category.Manager, delegate: CategoriesControllerDelegate) {
      // Phase 1.
      self.categoryManager = categoryManager
      coordinator = delegate
      
      // Phase 2.
      super.init(style: .grouped)
      
      // Phase 3.
      tableView.register(
         CategoriesTableViewCell.self,
         forCellReuseIdentifier: CategoriesTableViewCell.identifier
      )
      tableView.register(
         CategoryModificationTableViewCell.self,
         forCellReuseIdentifier: CategoryModificationTableViewCell.identifier
      )
      
      tableView.rowHeight = .defaultHeight
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      coordinator.setupNavigationBar(for: self)
      tableView.reloadData()
   }
   
   // MARK: - Requirements
   
   required init?(coder aDecoder: NSCoder) { fatalError("App does not use storyboard or XIB.") }
}

// MARK: - Table View Cell Creation

extension CategoriesController {
   
   enum Section: Int, CaseIterable {
      case categories
      case modifiers
   }

   override func numberOfSections(in tableView: UITableView) -> Int {
      return Section.allCases.count
   }
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return (section == Section.categories.rawValue) ? categoryManager.categories.count : 1
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
   -> UITableViewCell {
      if indexPath.section == Section.categories.rawValue {
         guard
            let cell = tableView.dequeueReusableCell(
               withIdentifier: CategoriesTableViewCell.identifier, for: indexPath
            ) as? CategoriesTableViewCell
         else { fatalError("Dequeued unexpected type of table view cell.") }
         
         setupCell(cell, forRow: indexPath.row)
         return cell
      } else {
         guard
            let cell = tableView.dequeueReusableCell(
               withIdentifier: CategoryModificationTableViewCell.identifier, for: indexPath
            ) as? CategoryModificationTableViewCell
         else { fatalError("Dequeued unexpected type of table view cell.") }
         
         cell.datasource = self
         return cell
      }
   }
   
   private func setupCell(_ cell: CategoriesTableViewCell, forRow row: Int) {
      let category = categoryManager.categories[row]
      
      cell.title = category.title
      cell.color = category.color
      cell.titleTextField.delegate = self
      cell.setTarget(self, action: #selector(colorDotWasTapped(_:)))
   }
}

// MARK: - Table View Editing

extension CategoriesController {

   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      return (indexPath.section == Section.categories.rawValue)
   }
   
   override func tableView(
      _ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
      toProposedIndexPath proposedDestinationIndexPath: IndexPath
   ) -> IndexPath {
      guard proposedDestinationIndexPath.section == Section.modifiers.rawValue
      else { return proposedDestinationIndexPath }
      
      let lastRow = tableView.numberOfRows(inSection: Section.categories.rawValue) - 1
      return IndexPath(row: lastRow, section: Section.categories.rawValue)
   }
   
   override func tableView(
      _ tableView: UITableView,
      commit editingStyle: UITableViewCell.EditingStyle,
      forRowAt indexPath: IndexPath
   ) {
      guard case .delete = editingStyle else { return }
      
      let category = categoryManager.categories[indexPath.row]
      
      let conformationController = UIAlertController(
         title: "Delete \"\(category.title)\"?",
         message: "All tracks for this category will be removed.",
         preferredStyle: .alert
      )
      
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
      let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
         self.categoryManager.remove(atIndex: indexPath.row)
         tableView.deleteRows(at: [indexPath], with: .automatic)
      }
   
      conformationController.addAction(deleteAction)
      conformationController.addAction(cancelAction)
      
      present(conformationController, animated: true, completion: nil)
   }
   
   override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
      return (indexPath.section == Section.categories.rawValue)
   }
   
   override func tableView(
      _ tableView: UITableView,
      moveRowAt sourceIndexPath: IndexPath,
      to destinationIndexPath: IndexPath
   ) {
      categoryManager.move(categoryAtIndex: sourceIndexPath.row, to: destinationIndexPath.row)
   }
}

// MARK: - Category Modification Table View Cell Data Source

extension CategoriesController: CategoryModificationTableViewCellDataSource {
   
   private enum ModificationAction: Int, CaseIterable {
      case add
      case edit
   }
   
   func numberOfActionsForTableViewCell(_ cell: CategoryModificationTableViewCell) -> Int {
      return ModificationAction.allCases.count
   }
   
   func tableViewCell(
      _ categoryModificationTableViewCell: CategoryModificationTableViewCell,
      needsSetupForCell cell: CategoryModificationActionCell,
      atRow row: Int
   ) {
      let actionTitle: String
      let buttonType: ImageLoader.Button
      let targetAction: (taget: Any?, action: Selector)
      
      switch ModificationAction(rawValue: row) {
      case .add?:
         actionTitle = "Add"
         buttonType = .add
         targetAction = (self, #selector(didRequestNewCategory))
         
      case .edit?:
         actionTitle = isEditing ? "End Editing" : "Edit"
         buttonType = isEditing ? .stop : .home
         targetAction = (self, #selector(didRequestEditToggle))
         
         cell.imageView.fadeTransition(duration: 0.3)
         cell.textLabel.fadeTransition(duration: 0.3)
         
      default:
         fatalError("Internal inconsistency between data source methods.")
      }
      
      let imageSize = CGSize(width: 40, height: 40)
      let imageLoader = ImageLoader(useDefaultSizes: false)
      let image = imageLoader[button: buttonType].resizedKeepingAspect(forSize: imageSize)
      
      cell.text = actionTitle
      cell.image = image
      cell.textLabel.isUserInteractionEnabled = false
      cell.imageView.isUserInteractionEnabled = false
      cell.addGestureRecognizer(
         UITapGestureRecognizer(target: targetAction.0, action: targetAction.1)
      )
   }
   
   @objc private func didRequestNewCategory() {
      coordinator.categoriesControllerDidRequestNewCategory(self)
   }
   
   @objc private func didRequestEditToggle() {
      setEditing(!isEditing, animated: true)
      let editActionPath = IndexPath(row: 0, section: Section.modifiers.rawValue)
      
      guard
         let modificationCell = tableView.cellForRow(at: editActionPath)
         as? CategoryModificationTableViewCell
      else {
         fatalError("Received table view cell of unexpected type.")
      }
      
      modificationCell.collectionView.reloadData()
   }
}

// MARK: - Color Picker Handler

extension CategoriesController {
   
   @objc private func colorDotWasTapped(_ cell: CategoriesTableViewCell) {
      coordinator.categoriesController(self, didTapColorDotForCell: cell)
   }
}

// MARK: - Text Field Delegate

extension CategoriesController: UITextFieldDelegate {
   
   private func category(associatedWith textField: UITextField) -> Category? {
      let categoriesCellCount = tableView.numberOfRows(inSection: Section.categories.rawValue)
      for row in 0..<categoriesCellCount {
         let indexPath = IndexPath(row: row, section: Section.categories.rawValue)
         guard let cell = tableView.cellForRow(at: indexPath) as? CategoriesTableViewCell else {
            fatalError("Accessed unexpected type of table view cell.")
         }
         
         if cell.titleTextField === textField { return categoryManager.categories[row] }
      }
      
      return nil
   }
   
   func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
      textField.returnKeyType = .done
      return true
   }
   
   func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      guard let trimmedText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
         fatalError("Expected text field to contain text.")
      }
      guard let category = category(associatedWith: textField) else {
         fatalError("Expected to find a category associated with the text field.")
      }
      
      guard categoryManager.rename(category: category, to: trimmedText) else {
         textField.resignFirstResponder()
         
         let explainationController = UIAlertController(
            title: "Invalid Title",
            message: "A title can not be empty or in use.",
            preferredStyle: .alert
         )
         let changeTitleAction = UIAlertAction(title: "Change Title", style: .default) { _ in
            textField.becomeFirstResponder()
         }
         let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            textField.fadeTransition(duration: 0.3)
            textField.text = category.title
         }
         
         explainationController.addAction(changeTitleAction)
         explainationController.addAction(cancelAction)
         
         present(explainationController, animated: true, completion: nil)
         return false
      }
      
      textField.text = trimmedText
      textField.resignFirstResponder()
      return true
   }
   
   func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
      guard let category = category(associatedWith: textField) else {
         fatalError("Expected to find a category associated with the text field.")
      }
      textField.fadeTransition(duration: 0.4)
      textField.text = category.title
      return true
   }
   
   func textField(
      _ textField: UITextField,
      shouldChangeCharactersIn range: NSRange,
      replacementString replacement: String
   ) -> Bool {
      let oldText = (textField.text ?? "") as NSString
      let newText = oldText.replacingCharacters(in: range, with: replacement)
      
      return newText.count <= 30
   }
}
