//
//  EditableCategoryCell.swift
//  Track
//
//  Created by Marcus Rossel on 04.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

/// A category cell that simplifies editing of the category.
final class EditableCategoryCell: CategoryCell {

   /// An identifier associated with the table view cell.
   /// This can be used when registering and dequeueing a categories cell.
   override static var identifier: String { return "EditableCategoryCell" }
   
   /// A handler that is called when the color dot is tapped.
   var colorTapHandler: ((EditableCategoryCell) -> ())? {
      didSet { colorDot.isUserInteractionEnabled = (colorTapHandler != nil) }
   }
   
   override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      // Phase 2.
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      
      // Phase 3.
      textField.isUserInteractionEnabled = true
      
      colorDot.addGestureRecognizer(
         UITapGestureRecognizer(target: self, action: #selector(colorDotWasTapped))
      )
   }
   
   /// An action method, delegating taps of the color dot to the handler.
   @objc private func colorDotWasTapped() {
      colorTapHandler?(self)
   }
   
   // MARK: - Requirements
   
   /// Do not call this initializer! This view does not support storyboards or XIB.
   required init?(coder aDecoder: NSCoder) { fatalError("View doesn't support storyboard or XIB.") }
}
