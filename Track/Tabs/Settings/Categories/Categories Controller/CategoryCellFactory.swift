//
//  CategoryCellFactory.swift
//  Track
//
//  Created by Marcus Rossel on 09.10.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

#warning("Pull out all of the callbacks, and require them from a data source.")

extension CategoriesController {
   final class CellFactory {
      
      private unowned var owner: CategoriesController
      private var logicController: CategoriesLogicController
   
      init(owner: CategoriesController, logicController: CategoriesLogicController) {
         self.owner = owner
         self.logicController = logicController
      }
      
      func setupCategoriesCell(
         _ cell: EditableCategoryCell,
         fromContainer container: CategoryContainer,
         withColorTapHandler tapHandler: ((EditableCategoryCell) -> ())?
      ) {
         cell.title = container.title
         cell.color = container.color
         cell.textField.delegate = owner
         cell.colorTapHandler = tapHandler
         
         if container is Category.Prototype {
            cell.backgroundColor = UIColor(white: 0.95, alpha: 1)
         }
      }
      
      func setupModifierCell(
         _ cell: ButtonCell,
         forModificationAction modificationAction: ModificationAction
      ) {
         // Sets up the button cell individually for every modification action.
         switch modificationAction {
         case .add:
            setupAddModifierCell(cell)
         case .edit:
            // Toggles between the edit and end-editing representation of the edit button depending on
            // whether the table view is currently in editing mode.
            cell.title = owner.isEditing ? "End Editing" : "Edit"
            cell.buttonImage = modifierCellImage(for: owner.isEditing ? .stop : .home)
            cell.tapHandler = toggleEditHandler
         }
      }
      
      private func setupAddModifierCell(_ cell: ButtonCell) {
         cell.title = "Add"
         cell.buttonImage = modifierCellImage(for: .add)
         cell.tapHandler = { _ in
            let prototypeRow = self.logicController.addPrototype()
            let prototypePath = IndexPath(row: prototypeRow, section: Section.categories.rawValue)
            self.owner.tableView.beginUpdates()
            self.owner.tableView.insertRows(at: [prototypePath], with: .automatic)
            self.owner.tableView.endUpdates()
         }
      }
      
      /// The tap handler for the edit button.
      private func toggleEditHandler(_ cell: ButtonCell) {
         // Toggles the editing mode.
         owner.setEditing(!owner.isEditing, animated: true)
         
         // Gets the path of the cell that induced the toggle.
         let editCellPath = IndexPath(
            row: ModificationAction.edit.rawValue,
            section: Section.modifiers.rawValue
         )
         
         // Reloads the cell that induced the toggle.
         owner.tableView.reloadRows(at: [editCellPath], with: .fade)
      }
      
      /// A convenience method for getting a button image sized for a cell in the modifiers section.
      private func modifierCellImage(for buttonType: ImageLoader.Button) -> UIImage {
         let imageLoader = ImageLoader(useDefaultSizes: false)
         let image = imageLoader[button: buttonType]
         let imageSize = CGSize(width: 40, height: 40)
         
         return image.resizedKeepingAspect(forSize: imageSize)
      }
   }
}
