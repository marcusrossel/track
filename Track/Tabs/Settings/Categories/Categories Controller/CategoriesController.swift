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
   
   /// An enum describing the states in which a categories controller can be.
   enum State {
      case idle
      case editing
      case modifyingTitle(containerIndex: Int)
   }
   
   /// The current state of the categories controller.
   private(set) var state: State

   /// A coordinator that provides external (delegate) functionality.
   weak var delegate: CategoriesControllerDelegate?
   
   /// A logic controller specific to the categories controller.
   private var logicController: CategoriesLogicController!
   
   /// The factory used by the controller, to generate its table view cells.
   private var cellFactory: CellFactory!
   
   /// The category containers currently being shown by the categories controller.
   var categoryContainers: [CategoryConvertible] {
      return logicController.categoryContainers
   }
   
   /// Creates a new categories controller from a category manager.
   /// Optionally a delegate can be provided to add external functionality.
   init(categories: [Category], delegate: CategoriesControllerDelegate? = nil) {
      // Phase 1.
      state = .idle
      self.delegate = delegate
      
      // Phase 2.
      super.init(style: .grouped)
      
      // Phase 3.
      logicController = CategoriesLogicController(categories: categories)
      
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
      case .categories: return categoryContainers.count
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
         let container = categoryContainers[indexPath.row]
         
         return cellFactory.makeCategoryCell(for: indexPath, fromContainer: container) { cell in
            self.delegate?.categoriesController(
               self, needsColorChangeForContainerAtIndexPath: indexPath
            )
         }
         
      case .modifiers:
         // Sets up and returns the cell.
         guard let modificationAction = ModificationAction(rawValue: indexPath.row) else {
            fatalError("Internal inconsistency in categories controller.")
         }
         
         let handler: (ButtonCell) -> () = [.add: addAction, .edit: editAction][modificationAction]!

         return cellFactory.makeModifierCell(
            for: indexPath, fromModificationAction: modificationAction, withHandler: handler
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
      // Toggles the editing mode and updates the state accordingly.
      setEditing(!isEditing, animated: true)
      state = isEditing ? .editing : .idle
      
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
      guard let category = categoryContainers[indexPath.row] as? Category else {
         let removed = logicController.removeContainer(at: indexPath.row)
         self.tableView.deleteRows(at: [indexPath], with: .automatic)
         
         // Propagates the event to the delegate, if the removed container was a category.
         if removed is Category {
            delegate?.categoriesController(self, didRemoveCategoryAtIndex: indexPath.row)
         }
         
         return
      }

      // Prompts the user for confirmation of deletion and only then deletes the category.
      promptForDeletionConfirmation(of: category) {
         let removed = self.logicController.removeContainer(at: indexPath.row)
         tableView.deleteRows(at: [indexPath], with: .automatic)
         
         // Propagates the event to the delegate, if the removed container was a category.
         if removed is Category {
            self.delegate?.categoriesController(self, didRemoveCategoryAtIndex: indexPath.row)
         }
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
         preferredStyle: .actionSheet
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
      
      // Propagates the event to the delegate, if the moved container was a category.
      if let indices = logicController.moveContainer(at: sourcePath.row, to: destinationPath.row) {
         delegate?.categoriesController(
            self,
            didMoveCategoryAtIndex: indices.categoryOrigin,
            toIndex: indices.categoryDestination
         )
      }
   }
}

// MARK: - Text Field Delegate

extension CategoriesController: UITextFieldDelegate {
   
   private func cellIndex(associatedWith textField: UITextField) -> Int? {
      let categoriesCellCount = tableView.numberOfRows(inSection: Section.categories.rawValue)
      
      for row in 0..<categoriesCellCount {
         let indexPath = IndexPath(row: row, section: Section.categories.rawValue)
         
         guard let cell = tableView.cellForRow(at: indexPath) as? EditableCategoryCell else {
            fatalError("Accessed unexpected type of table view cell.")
         }
         
         if cell.textField === textField { return row }
      }
      
      return nil
   }
   
   /// Editing is only allowed if the controller is in the idle state.
   func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
      // Makes sure the controller is in the idle state.
      guard case .idle = state else { return false }
      
      // Gets the container being modified.
      guard let cellIndex = cellIndex(associatedWith: textField) else {
         fatalError("Internal inconsistency in categories controller.")
      }
      
      // Transfers to the editing state and propagates that event to the delegate.
      state = .modifyingTitle(containerIndex: cellIndex)
      tableView.reloadSections([Section.modifiers.rawValue], with: .automatic)      
      
      delegate?.categoriesControllerDidStartEditingCategoryTitle(self)
      
      return true
   }
   
   /// Makes sure the text field does not implement its "default behaviour" upon pressing the return
   /// button.
   func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.resignFirstResponder()
      return false
   }
   
   func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
      // Makes sure the controller is even in the right state for ending text field editing.
      guard case .modifyingTitle(let containerIndex) = state else {
         fatalError("Internal inconsistency in categories controller.")
      }
      
      // Gets the text field's text in trimmed form.
      guard let trimmedText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
         fatalError("Expected text field to contain text.")
      }
      
      // Handles ending editing differently for categories and prototypes.
      switch categoryContainers[containerIndex] {
      case let category as Category:
         // Indicates success if the category's title has not changed.
         guard category.title != trimmedText else { break }
         
         // Tries to rename the category and records if that was successful.
         let renameSuccess = category.rename(to: trimmedText)
         
         // Does not allow ending editing if the rename was unsuccessful.
         guard renameSuccess else {
            explainContinuedEditing()
            return false
         }
         
      case let prototype as Category.Prototype:
         // Renames the prototype and tries to turn it into a category.
         prototype.title = trimmedText
         
         // Tries to categorize the prototype and notifies the delegate upon success.
         if let (newCategory, categoryIndex) = logicController.categorize(prototype) {
            delegate?.categoriesController(
               self, didAddCategory: newCategory, atIndex: categoryIndex
            )
         }
         
         // Ending the editing of a prototype is always successful.
         
      default:
         fatalError("Non exhaustive switch over variable domain.")
      }
      
      // This point is only reached if editing is allowed to be ended.
      return true
   }
   
   func textFieldDidEndEditing(_ textField: UITextField) {
      // Makes sure the controller is even in the right state for ending text field editing.
      guard case .modifyingTitle(let containerIndex) = state else {
         fatalError("Internal inconsistency in categories controller.")
      }
      
      // Reloads the cell that was modified.
      let containerPath = IndexPath(row: containerIndex, section: Section.categories.rawValue)
      tableView.reloadRows(at: [containerPath], with: .automatic)
      
      // Returns the controller to the idle state and reenables the modifier buttons.
      state = .idle
      tableView.reloadSections([Section.modifiers.rawValue], with: .automatic)
      
      // Propagates the event to the delegate.
      delegate?.categoriesControllerDidEndEditingCategoryTitle(self)
   }

   /// Shows an alert view explaining why text field editing could not be ended.
   private func explainContinuedEditing() {
      let explainationController = UIAlertController(
         title: "Invalid Title",
         message: "A title can not be empty or in use.",
         preferredStyle: .alert
      )
      let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      
      explainationController.addAction(okAction)
      
      present(explainationController, animated: true, completion: nil)
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
protocol CategoriesControllerDelegate: AnyObject {
   
   func categoriesController(
      _ categoriesController: CategoriesController, didRemoveCategoryAtIndex index: Int
   )
   
   func categoriesController(
      _ categoriesController: CategoriesController,
      didMoveCategoryAtIndex source: Int,
      toIndex destination: Int
   )
   
   func categoriesController(
      _ categoriesController: CategoriesController,
      didAddCategory newCategory: Category,
      atIndex index: Int
   )
   
   func categoriesController(
      _ controller: CategoriesController,
      needsColorChangeForContainerAtIndexPath containerIndexPath: IndexPath
   )
   
   func categoriesControllerDidStartEditingCategoryTitle(
      _ categoriesController: CategoriesController
   )
   
   func categoriesControllerDidEndEditingCategoryTitle(
      _ categoriesController: CategoriesController
   )
}
