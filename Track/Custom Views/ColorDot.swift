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
         // Resizes the circle to the new diameter.
         frame = CGRect(origin: frame.origin, size: ColorDot.size(for: diameter))
         setDrawPaths()
      }
   }
   
   /// The color of the circle.
   var color: UIColor {
      didSet { setDrawPaths() }
   }
   
   /// The path of the outer border of the color dot, when being drawn.
   private(set) var circlePath = UIBezierPath()
   
   /// The path of the inner ring of the color dot, when being drawn.
   private(set) var ringPath = UIBezierPath()
   
   /// A property that affects how the color dot is drawn.
   private var colorIsLight: Bool { return color.luminosity > 0.95 }
   
   init(diameter: CGFloat, color: UIColor) {
      // Phase 1.
      self.diameter = diameter
      self.color = color
      
      // Phase 2.
      super.init(frame: CGRect(origin: .zero, size: ColorDot.size(for: diameter)))
      
      // Phase 3.
      setDrawPaths()
      backgroundColor = .clear
   }

   /// Draws the circle with the specified diameter and color.
   /// If the color is too light and accent ring is added to the ring.
   override func draw(_ rect: CGRect) {
      let colorIsLight = color.luminosity > 0.95
      let lineWidth = diameter / 40
      let drawDiameter = colorIsLight ? (diameter - lineWidth) : diameter
      
      // Gets needed paths.
      let circle = circlePath(diameter: drawDiameter, rect: rect)
      let ring = circlePath(diameter: 0.85 * drawDiameter, rect: rect)
      
      // Fills the circle.
      color.setFill()
      circle.fill()
      
      // Sets stroke properties.
      circle.lineWidth = lineWidth
      ring.lineWidth = lineWidth
      UIColor.white.setStroke()
      
      // Makes adjustments if the color is to light.
      if colorIsLight {
         UIColor(white: 0.8, alpha: 1).setStroke()
         circle.stroke()
      }
      
      ring.stroke()
   }
   
   /// Sets the `circlePath` and `ringPath` that are used to draw the color dot, for the current
   /// frame and color.
   private func setDrawPaths() {
      let colorIsLight = color.luminosity > 0.95
      let lineWidth = diameter / 40
      let drawDiameter = colorIsLight ? (diameter - lineWidth) : diameter
      
      circlePath = circlePath(diameter: drawDiameter, rect: frame)
      ringPath = circlePath(diameter: 0.85 * drawDiameter, rect: frame)
   }
   
   /// Creates a circular path at a given diameter in the center of a given rect.
   private func circlePath(diameter: CGFloat, rect: CGRect) -> UIBezierPath {
      return UIBezierPath(
         arcCenter: rect.center,
         radius: diameter / 2,
         startAngle: 0,
         endAngle: 360.degreesAsRadians,
         clockwise: true
      )
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
