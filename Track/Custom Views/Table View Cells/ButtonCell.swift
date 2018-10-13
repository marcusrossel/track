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
   
   /// An indicator for whether the button cell calls its tap handler when being tapped.
   var isEnabled: Bool = true {
      didSet {
         textField.textColor = isEnabled ? #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1) : #colorLiteral(red: 0.5960784314, green: 0.5960784314, blue: 0.6156862745, alpha: 1)
         leadingView.tintColor = isEnabled ? #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1) : #colorLiteral(red: 0.5960784314, green: 0.5960784314, blue: 0.6156862745, alpha: 1)
      }
   }
   
   /// The handler that is called when the cell is tapped.
   var tapHandler: ((ButtonCell) -> ())?
   
   /// The image representing the button.
   var buttonImage: UIImage? {
      get { return (leadingView as? UIImageView)?.image }
      set { (leadingView as? UIImageView)?.image = newValue?.withRenderingMode(.alwaysTemplate) }
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
      setupTextField()
      setupImageView()
      
      contentView.addGestureRecognizer(
         UITapGestureRecognizer(target: self, action: #selector(cellWasTapped))
      )
   }
   
   private func setupTextField() {
      textField.isUserInteractionEnabled = false
      
      let fontDescriptor = UIFont.preferredFont(forTextStyle: .body).fontDescriptor
      textField.font = UIFont(descriptor: fontDescriptor, size: UIFont.buttonFontSize)
      textField.textColor = #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1)
   }
   
   /// Sets up the cell's leading view as an image view.
   private func setupImageView() {
      leadingView = UIImageView()
      leadingView.isUserInteractionEnabled = false
   }
   
   /// An action method, delegating taps of the cell to the handler.
   @objc private func cellWasTapped() {
      // Only calls the tap handler if the button cell is enabled.
      guard isEnabled else { return }
      
      tapHandler?(self)
   }
   
   // MARK: - Requirements
   
   /// Do not call this initializer! This view does not support storyboards or XIB.
   required init?(coder aDecoder: NSCoder) { fatalError("View doesn't support storyboard or XIB.") }
}
