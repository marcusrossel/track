//
//  CategoryCell.swift
//  Track
//
//  Created by Marcus Rossel on 04.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

/// The table view cell used for displaying categories.
class CategoryCell: ViewTextFieldCell {
   
   /// An identifier associated with the table view cell.
   /// This can be used when registering and dequeueing a categories cell.
   override class var identifier: String { return "CategoryCell" }
   
   /// A convenience accessor for the cell's color dot.
   private(set) var colorDot: ColorDot {
      get {
         guard let dot = leadingView as? ColorDot else {
            fatalError("Expected leading view in category cell to be of type `ColorDot`.")
         }
         return dot
      }
      set { leadingView = newValue }
   }
   
   /// The string shown in the cell's text field (representing the category's title).
   var title: String {
      get {
         guard let text = textField.text else {
            fatalError("Expected text field to always contain text.")
         }
         return text
      }
      set { textField.text = newValue }
   }
   
   /// The color shown in the cell's color dot (representing the category's color).
   var color: UIColor {
      get { return colorDot.color }
      set { colorDot.color = newValue }
   }
   
   override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      // Phase 2.
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      
      // Phase 3.
      colorDot = ColorDot(diameter: 40, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
      colorDot.isUserInteractionEnabled = false
      
      setupTextField()
   }
   
   private func setupTextField() {
      title = ""
      textField.isUserInteractionEnabled = false
      textField.font = UIFont.preferredFont(forTextStyle: .body)
      
      // Sets up layout constraints.
      let heightRatio = colorDot.ringPath.bounds.height / colorDot.circlePath.bounds.height
      textField.heightAnchor.constraint(
         equalTo: colorDot.heightAnchor, multiplier: heightRatio
      ).isActive = true
   }
   
   // MARK: - Requirements
   
   /// Do not call this initializer! This view does not support storyboards or XIB.
   required init?(coder aDecoder: NSCoder) { fatalError("View doesn't support storyboard or XIB.") }
}
