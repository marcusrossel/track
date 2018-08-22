//
//  ColorDot.swift
//  Track
//
//  Created by Marcus Rossel on 17.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

/// A view displaying a circle of given diameter and color.
final class ColorDot: UIView {

   /// The diameter of the circle.
   var diameter: CGFloat {
      didSet {
         // Adjust the frame and corner radius to resize the circle to the new diameter.
         layer.cornerRadius = diameter / 2
         frame = CGRect(origin: frame.origin, size: ColorDot.size(for: diameter))
      }
   }
   
   /// The color of the circle.
   /// A color dot always has a visible color, so it can never have an alpha value of `0`.
   /// Attempting to assign a color with an alpha of `0` will have no effect.
   var color: UIColor {
      didSet {
         guard color.cgColor.alpha != 0 else {
            color = oldValue
            return
         }
         backgroundColor = color
      }
   }
   
   init(diameter: CGFloat, color: UIColor) {
      // Phase 1.
      self.diameter = diameter
      self.color = color
      
      // Phase 2.
      super.init(frame: CGRect(origin: .zero, size: ColorDot.size(for: diameter)))
      
      // Phase 3.
      callPropertySetters(color: color, diameter: diameter)
      constrainAspectRatio()
   }
   
   /// Forces the propery setters to be called.
   private func callPropertySetters(color: UIColor, diameter: CGFloat) {
      self.color = color
      self.diameter = diameter
   }
   
   /// Constrains the view to always be squared, to avoid the circle from becoming an oval.
   private func constrainAspectRatio() {
      let squareRatio = heightAnchor.constraint(equalTo: widthAnchor)
      squareRatio.priority = .required
      
      NSLayoutConstraint.activate([squareRatio])
   }
   
   // MARK: - Requirements
   
   /// Do not call this initializer! This view does not support storyboards or XIB.
   required init?(coder aDecoder: NSCoder) { fatalError("View doesn't support storyboard or XIB.") }
}

// MARK: - View Properties

extension ColorDot {
   
   /// A convenience function for getting the (square) size associated with a diameter.
   private static func size(for diameter: CGFloat) -> CGSize {
      return CGSize(width: diameter, height: diameter)
   }
   
   /// A color dot's initrinsic content size is a square for its diameter.
   override var intrinsicContentSize: CGSize {
      return ColorDot.size(for: diameter)
   }
   
   /// A color dot always has a visible color, so it can never have an alpha value of `0`.
   /// Attempting to assign a `nil`, or a color with an alpha of `0` will have no effect.
   override var backgroundColor: UIColor? {
      didSet {
         guard let newColor = backgroundColor, newColor.cgColor.alpha != 0 else {
            backgroundColor = oldValue
            return
         }
      }
   }
}
