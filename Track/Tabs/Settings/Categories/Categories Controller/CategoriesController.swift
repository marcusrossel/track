//
//  CategoriesController.swift
//  Track
//
//  Created by Marcus Rossel on 16.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Categoties Controller Delegate

/// A delegate providing functionality external to a categories controller.
protocol CategoriesControllerDelegate {
   
   func categoriesController(
      _ controller: CategoriesController, didTapColorDotForCell cell: EditableCategoryCell
   )
   
   func categoriesControllerDidRequestNewCategory(_ controller: CategoriesController)
   
   func setupNavigationBar(for controller: CategoriesController)
}

extension CategoriesControllerDelegate {
   
   /// A default implementation for the `setupNavigationBar(for:)`-method, to make its
   /// implementation effectively optional.
   func setupNavigationBar(for controller: CategoriesController) { }
}

// MARK: - Categories Controller

/// A view controller that displays a list of all categories and allows editing of their title and
/// color. They can also be reordered or deleted.
/// Additionally the controller provides the pathway for adding new categories.
final class CategoriesController: UITableViewController {

   /// A coordinator that provides external (delegate) functionality.
   private var coordinator: CategoriesControllerDelegate?
   
   /// A category manager giving the controller access to all categories.
   private let categoryManager: Category.Manager
   
   /// Creates a new categories controller from a category manager.
   /// Optionally a delegate can be provided to add external functionality.
   init(categoryManager: Category.Manager, delegate: CategoriesControllerDelegate? = nil) {
      // Phase 1.
      self.categoryManager = categoryManager
      coordinator = delegate
      
      // Phase 2.
      super.init(style: .grouped)
      
      // Phase 3.
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
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      // A navigation bar has the chance to be updated on appearance of the controller.
      coordinator?.setupNavigationBar(for: self)
      
      // The table view should always reload its data on appearance, as to capture changes that
      // might have been made to categories externally.
      tableView.reloadData()
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
   private enum ModificationAction: Int, CaseIterable {
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
      switch Section(rawValue: section) {
      case .categories?: return categoryManager.categories.count
      case .modifiers?: return ModificationAction.allCases.count
      default: fatalError("Non exhaustive switch over variable domain.")
      }
   }
   
   /// Delegates the setup of the cell to a different method according to it section.
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
   -> UITableViewCell {
      #warning("Efficiency: Not reusing cells.")
      // Sets up the cell according to its section.
      switch Section(rawValue: indexPath.section) {
      case .categories?:
         let cell = EditableCategoryCell(
            style: .default, reuseIdentifier: EditableCategoryCell.identifier
         )
         
         // Sets up and returns the cell.
         setupCategoriesCell(cell, forRow: indexPath.row)
         return cell
         
      case .modifiers?:
         let cell = ButtonCell(style: .default, reuseIdentifier: ButtonCell.identifier)
         
         // Sets up and returns the cell.
         setupModifierCell(cell, forRow: indexPath.row)
         return cell
         
      default:
         fatalError("Non exhaustive switch over variable domain.")
      }
   }
}

// MARK: - Cell Setup

extension CategoriesController {
   
   /// A convenience method for setting up a cell from the categories section.
   private func setupCategoriesCell(_ cell: EditableCategoryCell, forRow row: Int) {
      let category = categoryManager.categories[row]
      
      cell.title = category.title
      cell.color = category.color
      cell.textField.delegate = self
      cell.colorTapHandler = {
         self.coordinator?.categoriesController(self, didTapColorDotForCell: $0)
      }
   }
   
   /// A convenience method for setting up a cell from the modifiers section.
   private func setupModifierCell(_ cell: ButtonCell, forRow row: Int) {
      
      // Sets up the button cell individually for every modification action.
      switch ModificationAction(rawValue: row) {
      case .add?:
         cell.title = "Add"
         cell.buttonImage = modifierCellImage(for: .add)
         cell.tapHandler = { _ in
            self.coordinator?.categoriesControllerDidRequestNewCategory(self)
         }
         
      case .edit?:
         // Toggles between the edit and end-editing representation of the edit button depending on
         // whether the table view is currently in editing mode.
         cell.title = isEditing ? "End Editing" : "Edit"
         cell.buttonImage = modifierCellImage(for: isEditing ? .stop : .home)
         cell.tapHandler = toggleEditHandler

      default:
         fatalError("Non exhaustive switch over variable domain.")
      }
   }
   
   /// The tap handler for the edit button.
   private func toggleEditHandler(_ cell: ButtonCell) {
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
   
   /// A convenience method for getting a button image sized for a cell in the modifiers section.
   private func modifierCellImage(for buttonType: ImageLoader.Button) -> UIImage {
      let imageLoader = ImageLoader(useDefaultSizes: false)
      let image = imageLoader[button: buttonType]
      let imageSize = CGSize(width: 40, height: 40)
      
      return image.resizedKeepingAspect(forSize: imageSize)
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
      
      let category = categoryManager.categories[indexPath.row]
      
      // Prompts the user for confirmation of deletion and only then deletes the category.
      promptForDeletionConfirmation(of: category) {
         self.categoryManager.remove(atIndex: indexPath.row)
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
      _ tableView: UITableView,
      moveRowAt sourceIndexPath: IndexPath,
      to destinationIndexPath: IndexPath
   ) {
      // Makes sure the reordering was valid.
      guard
         sourceIndexPath.section == Section.categories.rawValue &&
         destinationIndexPath.section == Section.categories.rawValue
      else {
         fatalError("Internal inconsistency in `CategoriesController`.")
      }
      
      // Changes the order of categories according to the cells.
      categoryManager.move(categoryAtIndex: sourceIndexPath.row, to: destinationIndexPath.row)
   }
}

// MARK: - Text Field Delegate
#warning("Buggy.")

extension CategoriesController: UITextFieldDelegate {
   
   private func category(associatedWith textField: UITextField) -> Category? {
      let categoriesCellCount = tableView.numberOfRows(inSection: Section.categories.rawValue)
      for row in 0..<categoriesCellCount {
         let indexPath = IndexPath(row: row, section: Section.categories.rawValue)
         guard let cell = tableView.cellForRow(at: indexPath) as? CategoryCell else {
            fatalError("Accessed unexpected type of table view cell.")
         }
         
         if cell.textField === textField { return categoryManager.categories[row] }
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
