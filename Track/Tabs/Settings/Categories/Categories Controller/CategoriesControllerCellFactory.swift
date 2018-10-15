//
//  CategoriesControllerCellFactory.swift
//  Track
//
//  Created by Marcus Rossel on 09.10.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

extension CategoriesController {
   /// A factory type, that is able to setup cells as required by a categories controller.
   /// This type is tightly coupled with the categories controller.
   final class CellFactory {
      
      /// The categories controller using the factory.
      /// Using the factory from any other instance can cause crashes!
      private unowned var owner: CategoriesController
   
      /// Creates a categories controller cell factory.
      init(owner: CategoriesController) {
         self.owner = owner
      }
      
      /// Uses a given category container to setup a category cell for a given index path.
      func makeCategoryCell(
         for indexPath: IndexPath,
         fromContainer container: CategoryConvertible,
         withColorTapHandler tapHandler: ((EditableCategoryCell) -> ())?
      ) -> EditableCategoryCell {
         // Gets the cell.
         guard
            let cell = owner.tableView.dequeueReusableCell(
               withIdentifier: EditableCategoryCell.identifier, for: indexPath
            ) as? EditableCategoryCell
         else {
            fatalError("Dequeued unexpected type of table view cell.")
         }
         
         // Sets properties that are independant of container type.
         cell.textField.delegate = owner
         cell.colorTapHandler = tapHandler
         cell.title = container.title
         cell.color = container.color
         
         // Sets properties specific to prototypes.
         if container is Category.Prototype {
            cell.backgroundColor = #colorLiteral(red: 0.878935039, green: 0.878935039, blue: 0.878935039, alpha: 1)
         } else {
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
         }
         
         return cell
      }
      
      /// Uses a given modification action to setup a button cell at a given index path.
      func makeModifierCell(
         for indexPath: IndexPath,
         fromModificationAction modificationAction: ModificationAction,
         withHandler handler: ((ButtonCell) -> ())?
      ) -> ButtonCell {
         // Gets the cell.
         guard
            let cell = owner.tableView.dequeueReusableCell(
               withIdentifier: ButtonCell.identifier, for: indexPath
            ) as? ButtonCell
         else {
            fatalError("Dequeued unexpected type of table view cell.")
         }
         
         // Sets up the button cell individually for every modification action.
         switch modificationAction {
         case .add:
            cell.title = "Add"
            cell.buttonImage = modifierCellImage(for: .add)
         case .edit:
            // Toggles between the edit and end-editing representation of the edit button depending
            // on whether the categories controller is currently in editing mode.
            cell.title = owner.isEditing ? "End Editing" : "Edit"
            cell.buttonImage = modifierCellImage(for: owner.isEditing ? .stop : .home)
         }
         
         // Sets properties independant of modification action type.
         cell.tapHandler = handler
         if case .modifyingTitle = owner.state {
            cell.isEnabled = false
         } else {
            cell.isEnabled = true
         }
         
         return cell
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
