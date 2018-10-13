//
//  ViewTextFieldCell.swift
//  Track
//
//  Created by Marcus Rossel on 04.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

/// A table view cell with a leading view followed by a text field to the right.
class ViewTextFieldCell: UITableViewCell {

   /// An identifier associated with the table view cell.
   /// This can be used when registering and dequeueing a view text field cell.
   class var identifier: String { return "ViewTextFieldCell" }
   
   /// A view placed at the cell's leading edge.
   var leadingView = UIView() {
      didSet { reconstrain(view: leadingView, oldView: oldValue) }
   }
   
   /// A text field trailing the leading view.
   var textField = UITextField() {
      didSet { reconstrain(view: textField, oldView: oldValue) }
   }
   
   override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      // Phase 2.
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      
      // Phase 3.
      AutoLayoutHelper(rootView: contentView).setupViewsForAutoLayout([leadingView, textField])
      callPropertySetters()
   }
   
   /// Calls the setters of the stored properties, to cause their `didSet`-blocks to run.
   private func callPropertySetters() {
      leadingView = UIView()
      textField = UITextField()
   }
   
   /// A convenience accessor to the layout guide used during auto layout.
   private var layoutGuide: UILayoutGuide { return contentView.safeAreaLayoutGuide }
   
   /// A convenience method for readjusting the auto layout constraints when a given view replaces
   /// an old view.
   private func reconstrain(view: UIView, oldView: UIView) {
      // Deactivates and removes the old view.
      NSLayoutConstraint.deactivate(oldView.constraints)
      oldView.removeFromSuperview()
      
      AutoLayoutHelper(rootView: contentView).setupViewsForAutoLayout([view])
      
      view.centerYAnchor.constraint(equalTo: layoutGuide.centerYAnchor).isActive = true

      switch view {
      case _ where view === leadingView: constrainLeadingView()
      case _ where view === textField: constrainTextField()
      default: fatalError("Non exhaustive switch over variable domain.")
      }
   }
   
   /// A convenience method for setting up the leading view's auto layout constraints.
   private func constrainLeadingView() {
      leadingView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
      leadingView.setContentCompressionResistancePriority(.required, for: .horizontal)
      
      leadingView.leadingAnchor.constraint(
         equalTo: layoutGuide.leadingAnchor, constant: .defaultSpacing
      ).isActive = true
      
      leadingView.trailingAnchor.constraint(
         equalTo: textField.leadingAnchor, constant: -.defaultSpacing
      ).isActive = true
   }
   
   /// A convenience method for setting up the text field's auto layout constraints.
   private func constrainTextField() {      
      textField.leadingAnchor.constraint(
         equalTo: leadingView.trailingAnchor, constant: .defaultSpacing
      ).isActive = true
      
      textField.trailingAnchor.constraint(
         equalTo: layoutGuide.trailingAnchor, constant: -.defaultSpacing
      ).isActive = true
   }
   
   // MARK: - Requirements
   
   /// Do not call this initializer! This view does not support storyboards or XIB.
   required init?(coder aDecoder: NSCoder) { fatalError("View doesn't support storyboard or XIB.") }
}
