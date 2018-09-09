//
//  ButtonCell.swift
//  Track
//
//  Created by Marcus Rossel on 04.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

/// A table view cell behaving like a button.
final class ButtonCell: ViewTextFieldCell {

   /// An identifier associated with the table view cell.
   /// This can be used when registering and dequeueing a button cell.
   override class var identifier: String { return "ButtonCell" }
   
   /// The handler that is called when the cell is tapped.
   var tapHandler: ((ButtonCell) -> ())?
   
   /// The image representing the button.
   var buttonImage: UIImage? {
      get { return (leadingView as? UIImageView)?.image }
      set { (leadingView as? UIImageView)?.image = newValue }
   }
   
   /// The string shown in the cell's text field.
   var title: String {
      get {
         guard let text = textField.text else {
            fatalError("Expected text field to always contain text.")
         }
         return text
      }
      set { textField.text = newValue }
   }
   
   override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      // Phase 2.
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      
      // Phase 3.
      leadingView = UIImageView()
      
      leadingView.isUserInteractionEnabled = false
      textField.isUserInteractionEnabled = false
      
      contentView.addGestureRecognizer(
         UITapGestureRecognizer(target: self, action: #selector(cellWasTapped))
      )
   }
   
   /// An action method, delegating taps of the cell to the handler.
   @objc private func cellWasTapped() {
      tapHandler?(self)
   }
   
   // MARK: - Requirements
   
   /// Do not call this initializer! This view does not support storyboards or XIB.
   required init?(coder aDecoder: NSCoder) { fatalError("View doesn't support storyboard or XIB.") }
}
