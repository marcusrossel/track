//
//  CategoriesTableViewCell.swift
//  Track
//
//  Created by Marcus Rossel on 17.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

final class CategoriesTableViewCell: UITableViewCell {
   
   static let identifier = "CategoriesTableViewCell"
   
   private(set) var titleTextField = UITextField()
   private(set) var colorDot = ColorDot(diameter: 40, color: .black)
   
   override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      // Phase 2.
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      
      // Phase 3.
      titleTextField.text = ""
      accessoryType = .disclosureIndicator
      
      setupLayoutConstraints()
      
      let colorDotTapRecognizer = UITapGestureRecognizer(
         target: self, action: #selector(colorDotWasTapped)
      )
      colorDot.addGestureRecognizer(colorDotTapRecognizer)
      colorDot.isUserInteractionEnabled = false
   }
   
   // MARK: - Color Tap Handling
   private var colorTapHandler: (target: AnyObject, action: Selector)? {
      didSet { colorDot.isUserInteractionEnabled = (colorTapHandler != nil) }
   }

   @objc private func colorDotWasTapped() {
      guard let (target, action) = colorTapHandler else { return }
      let _ = target.perform(action, with: self)
   }
   
   // MARK: - Requirements
   
   required init?(coder aDecoder: NSCoder) { fatalError("App does not use storyboard or XIB.") }
}

// MARK: - Public API

extension CategoriesTableViewCell {
   
   var color: UIColor {
      get { return colorDot.color }
      set { colorDot.color = newValue }
   }
   
   var title: String {
      get {
         guard let title = titleTextField.text else {
            fatalError("Every categories table view cell is expected to have a title.")
         }
         return title
      }
      set { titleTextField.text = newValue }
   }
   
   func setTarget(_ target: AnyObject, action selector: Selector) {
      colorTapHandler = (target, selector)
   }
   
   func removeTarget(_ target: AnyObject, action selector: Selector) {
      colorTapHandler = nil
   }
}

// MARK: - Auto Layout

extension CategoriesTableViewCell {
   
   private func setupLayoutConstraints() {
      let stackView = UIStackView(arrangedSubviews: [colorDot, titleTextField])
      stackView.axis = .horizontal
      stackView.alignment = .center
      stackView.distribution = .fill
      stackView.spacing = .defaultSpacing
      
      setupViewsForAutoLayout([stackView])
      
      let guide = contentView.safeAreaLayoutGuide
      
      let top = stackView.topAnchor.constraint(equalTo: guide.topAnchor)
      let bottom = stackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
      let leading = stackView.leadingAnchor.constraint(
         equalTo: guide.leadingAnchor, constant: .defaultSpacing
      )
      
      NSLayoutConstraint.activate([top, bottom, leading])
   }
   
   private func setupViewsForAutoLayout(_ views: [UIView]) {
      for view in views {
         view.translatesAutoresizingMaskIntoConstraints = false
         contentView.addSubview(view)
      }
   }
}

