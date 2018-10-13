//
//  CategoriesController.swift
//  Track
//
//  Created by Marcus Rossel on 16.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Categories Controller

/// A view controller that displays a list of all categories and allows editing of their title and
/// color. They can also be reordered or deleted.
/// Additionally the controller provides the pathway for adding new categories.
final class CategoriesController: UITableViewController {

   /// A coordinator that provides external (delegate) functionality.
   weak var delegate: CategoriesControllerDelegate?
   
   /// A logic controller specific to the categories controller.
   private var logicController: CategoriesLogicController!
   
   private var cellFactory: CellFactory!
   
   /// Creates a new categories controller from a category manager.
   /// Optionally a delegate can be provided to add external functionality.
   init(categories: [Category], delegate: CategoriesControllerDelegate? = nil) {
      // Phase 1.
      self.delegate = delegate
      
      // Phase 2.
      super.init(style: .grouped)
      
      // Phase 3.
      logicController = CategoriesLogicController(
         owner: self, categories: categories, delegate: delegate
      )
      
      cellFactory = CellFactory(owner: self)
      
      setupTableView()
   }
   
   /// A convenience method for registering the table view's cells and setting its properties.
   private func setupTableView() {
      tableView.register(
         ButtonCell.self, forCellReuseIdentifier: ButtonCell.identifier
      )
      tableView.register(
         EditableCategoryCell.self, forCellReuseIdentifier: EditableCategoryCell.identifier
      )
      
      tableView.allowsSelection = false
      tableView.rowHeight = .defaultHeight
   }

   // MARK: - Requirements
   
   /// Do not call this initializer! This view does not support storyboards or XIB.
   required init?(coder aDecoder: NSCoder) { fatalError("View doesn't support storyboard or XIB.") }
}

// MARK: - Table View Data Source And Delegate

extension CategoriesController {
   
   /// All of the different sections shown by a categories controller.
   /// The order of the cases matches the order of the sections in the table view.
   enum Section: Int, CaseIterable {
      case modifiers
      case categories
   }
   
   /// All of the different actions on categories, that should be displayed as cells in the table
   /// view.
   enum ModificationAction: Int, CaseIterable {
      case add
      case edit
   }

   /// There are as many sections as cases in `Section`.
   override func numberOfSections(in tableView: UITableView) -> Int {
      return Section.allCases.count
   }
   
   /// There are as many rows:
   /// - .modifiers: as cases in `ModificationAction`.
   /// - .categories: as categories in the category manager.
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      guard let section = Section(rawValue: section) else {
         fatalError("Internal inconsistency in categories controller.")
      }
      
      switch section {
      case .categories: return logicController.categoryContainers.count
      case .modifiers: return ModificationAction.allCases.count
      }
   }
   
   /// Delegates the setup of the cell to a different method according to it section.
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
   -> UITableViewCell {
      
      guard let section = Section(rawValue: indexPath.section) else {
         fatalError("Internal inconsistency in categories controller.")
      }
      
      // Sets up the cell according to its section.
      switch section {
      case .categories:
         let container = logicController.categoryContainers[indexPath.row]
         
         return cellFactory.makeCategoryCell(for: indexPath, fromContainer: container) { cell in
            self.delegate?.categoriesController(self, didTapColorDotForCell: cell)
         }
         
      case .modifiers:
         
         // Sets up and returns the cell.
         guard let action = ModificationAction(rawValue: indexPath.row) else {
            fatalError("Internal inconsistency in categories controller.")
         }
         
         let actionMethod: (ButtonCell) -> () = [.add: addAction, .edit: editAction][action]!

         return cellFactory.makeModifierCell(
            for: indexPath, forModificationAction: action, withAction: actionMethod
         )
      }
   }
   
   private func addAction(_: ButtonCell) {
      let prototypeRow = self.logicController.addPrototype()
      let prototypePath = IndexPath(row: prototypeRow, section: Section.categories.rawValue)
      
      tableView.beginUpdates()
      tableView.insertRows(at: [prototypePath], with: .automatic)
      tableView.endUpdates()
   }
   
   private func editAction(_: ButtonCell) {
      // Toggles the editing mode.
      setEditing(!isEditing, animated: true)
      
      // Gets the path of the cell that induced the toggle.
      let editCellPath = IndexPath(
         row: ModificationAction.edit.rawValue,
         section: Section.modifiers.rawValue
      )
      
      // Reloads the cell that induced the toggle.
      tableView.reloadRows(at: [editCellPath], with: .fade)
   }
}

// MARK: - Table View Editing

extension CategoriesController {

   /// Allows editing of any cell in the categories section.
   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      return (indexPath.section == Section.categories.rawValue)
   }
   
   /// Makes sure the reordering of cells from the categories section stays within that section.
   override func tableView(
      _ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
      toProposedIndexPath proposedDestinationIndexPath: IndexPath
   ) -> IndexPath {
      // Allows the proposed destination if it is still in the categories section.
      guard proposedDestinationIndexPath.section != Section.categories.rawValue else {
         return proposedDestinationIndexPath
      }
      
      let proposedSection = proposedDestinationIndexPath.section
      let newRow: Int
      
      // Sets the cell's new row according to whether the cell was tried to be repositioned to a
      // section above or below the categories section.
      if proposedSection < Section.categories.rawValue {
         newRow = 0
      } else {
         newRow = tableView.numberOfRows(inSection: Section.categories.rawValue) - 1
      }
      
      // Moves the cell back to the categories section.
      return IndexPath(row: newRow, section: Section.categories.rawValue)
   }
   
   /// Handles the deletion of cells from the categories section.
   override func tableView(
      _ tableView: UITableView,
      commit editingStyle: UITableViewCell.EditingStyle,
      forRowAt indexPath: IndexPath
   ) {
      // Makes sure only the case of deletion is handled.
      guard case .delete = editingStyle else { return }
      
      // Deletes a the cell right away if it is just a prototype.
      guard case let .category(category) = logicController.categoryContainers[indexPath.row] else {
         logicController.removeContainer(at: indexPath.row)
         tableView.deleteRows(at: [indexPath], with: .automatic)
         return
      }

      // Prompts the user for confirmation of deletion and only then deletes the category.
      promptForDeletionConfirmation(of: category) {
         self.logicController.removeContainer(at: indexPath.row)
         tableView.deleteRows(at: [indexPath], with: .automatic)
      }
   }
   
   /// A convenience method for displaying a deletion alert view.
   private func promptForDeletionConfirmation(
      of category: Category,
      onConfirmation deletionHandler: @escaping () -> ()
   ) {
      // Creates an alert controller.
      let conformationController = UIAlertController(
         title: "Delete \"\(category.title)\"?",
         message: "All tracks for this category will be removed.",
         preferredStyle: .alert
      )
      
      // Creates the alert controllers actions and adds them to it.
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
      let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
         deletionHandler()
      }
      
      conformationController.addAction(deleteAction)
      conformationController.addAction(cancelAction)
      
      // Presents the alert controller.
      present(conformationController, animated: true, completion: nil)
   }
   
   /// Allows reordering of all cells in the categories section.
   override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
      return (indexPath.section == Section.categories.rawValue)
   }
   
   /// Propagates the reordering of cells from the categories section
   override func tableView(
      _ tableView: UITableView, moveRowAt sourcePath: IndexPath, to destinationPath: IndexPath
   ) {
      // Makes sure the reordering was valid.
      guard
         sourcePath.section == Section.categories.rawValue &&
         destinationPath.section == Section.categories.rawValue
      else {
         fatalError("Internal inconsistency in `CategoriesController`.")
      }
      
      logicController.moveContainer(at: sourcePath.row, to: destinationPath.row)
   }
}

// MARK: - Text Field Delegate
#warning("Broken")

extension CategoriesController: UITextFieldDelegate {
   
   private func category(associatedWith textField: UITextField) -> Category? {
      let categoriesCellCount = tableView.numberOfRows(inSection: Section.categories.rawValue)
      for row in 0..<categoriesCellCount {
         let indexPath = IndexPath(row: row, section: Section.categories.rawValue)
         guard let cell = tableView.cellForRow(at: indexPath) as? CategoryCell else {
            fatalError("Accessed unexpected type of table view cell.")
         }
         
         if cell.textField === textField {
            return logicController.categoryContainers[row] as? Category
         }
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
      
      guard category.rename(to: trimmedText) else {
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

// MARK: - Categories Controller Delegate

/// A delegate providing functionality external to a categories controller.
protocol CategoriesControllerDelegate: CategoriesLogicControllerDelegate {
   
   func categoriesController(
      _ controller: CategoriesController, didTapColorDotForCell cell: EditableCategoryCell
   )
}
