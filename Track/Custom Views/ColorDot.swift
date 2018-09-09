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
         // Adjusts the frame to resize the circle to the new diameter.
         frame = CGRect(origin: frame.origin, size: ColorDot.size(for: diameter))
      }
   }
   
   /// The color of the circle.
   var color: UIColor
   
   init(diameter: CGFloat, color: UIColor) {
      // Phase 1.
      self.diameter = diameter
      self.color = color
      
      // Phase 2.
      super.init(frame: CGRect(origin: .zero, size: ColorDot.size(for: diameter)))
      
      // Phase 3.
      backgroundColor = .clear
   }

   /// Draws the circle with the specified diameter and color.
   override func draw(_ rect: CGRect) {
      let path = UIBezierPath(
         arcCenter: rect.center,
         radius: diameter / 2,
         startAngle: 0,
         endAngle: 360.degreesAsRadians,
         clockwise: true
      )
      
      color.setFill()
      path.fill()
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
}
