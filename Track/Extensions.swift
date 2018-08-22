//
//  Extensions.swift
//  Track
//
//  Created by Marcus Rossel on 16.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

extension Int {
   
   var degreesAsRadians: CGFloat {
      return (CGFloat(self) * .pi) / 180
   }
}

extension TimeInterval {
   
   var decomposed: (hours: Int, minutes: Int, seconds: Int, remainder: TimeInterval) {
      let wholeSeconds = Int(self)
      
      let hours = wholeSeconds / (60 * 60)
      let minutes = (wholeSeconds / 60) % 60
      let seconds = wholeSeconds % 60
      let remainder = self - TimeInterval(wholeSeconds)
      
      return (hours, minutes, seconds, remainder)
   }
}

extension CGFloat {
   
   static var defaultSpacing: CGFloat {
      return 8
   }
   
   static var defaultHeight: CGFloat {
      return 60
   }
   
   static var tableViewBorder: CGFloat {
      return 1.5
   }
}

extension CGSize {
   
   static var defaultIcon: CGSize {
      return CGSize(width: 30, height: 30)
   }
}

extension UIView {
   
   func setDefaultShadow() {
      layer.shadowRadius = 8
      layer.shadowOpacity = 0.5
      layer.shadowOffset = .zero
      layer.shadowColor = UIColor.black.cgColor
   }
   
   func fadeTransition(duration: Double) {
      let animation = CATransition()
      animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
      animation.type = .fade
      animation.duration = duration
      
      layer.add(animation, forKey: CATransitionType.push.rawValue)
   }
}

extension UIColor {
   
   enum Component: Int, CaseIterable, Codable {
      case red
      case green
      case blue
      case alpha
   }
   
   var decomposed: [Component: CGFloat] {
      var red: CGFloat = .nan
      var green: CGFloat = .nan
      var blue: CGFloat = .nan
      var alpha: CGFloat = .nan
      
      getRed(&red, green: &green, blue: &blue, alpha: &alpha)
      
      return [.red: red, .green: green, .blue: blue, .alpha: alpha]
   }
   
   convenience init(components: [UIColor.Component: CGFloat]) {
      self.init(
         red: components[.red] ?? 0,
         green: components[.green] ?? 0,
         blue: components[.blue] ?? 0,
         alpha: components[.alpha] ?? 0
      )
   }
   
   static var tableViewBorder: UIColor {
      return UIColor(white: 0.9, alpha: 1)
   }
}

extension UIImage {
   
   func resized(forSize newSize: CGSize) -> UIImage {
      guard size != newSize else { return self }
      
      UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
      draw(in: CGRect(origin: .zero, size: newSize))
      
      let newImage = UIGraphicsGetImageFromCurrentImageContext()!
      UIGraphicsEndImageContext()
      
      return newImage
   }
   
   func resizedKeepingAspect(forSize newSize: CGSize) -> UIImage {
      let widthFactor = size.width / newSize.width
      let heightFactor = size.height / newSize.height
      let resizeFactor = (size.width > size.height) ? widthFactor : heightFactor
      
      let newSizeKeepingAspect = CGSize(
         width: size.width / resizeFactor, height: size.height / resizeFactor
      )
      return self.resized(forSize: newSizeKeepingAspect)
   }
}

extension UILabel {
   
   func fitTextToBounds() {
      guard let text = text, let currentFont = font else { return }
      
      let bestFittingFont = UIFont.bestFittingFont(for: text, in: bounds, fontDescriptor: currentFont.fontDescriptor, additionalAttributes: basicStringAttributes)
      font = bestFittingFont
   }
   
   private var basicStringAttributes: [NSAttributedString.Key: Any] {
      var attribs = [NSAttributedString.Key: Any]()
      
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.alignment = self.textAlignment
      paragraphStyle.lineBreakMode = self.lineBreakMode
      attribs[.paragraphStyle] = paragraphStyle
      
      return attribs
   }
}


extension UIFont {
   
   static func bestFittingFontSize(for text: String, in bounds: CGRect, fontDescriptor: UIFontDescriptor, additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> CGFloat {
      let constrainingDimension = min(bounds.width, bounds.height)
      let properBounds = CGRect(origin: .zero, size: bounds.size)
      var attributes = additionalAttributes ?? [:]
      
      let infiniteBounds = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
      var bestFontSize: CGFloat = constrainingDimension
      
      for fontSize in stride(from: bestFontSize, through: 0, by: -1) {
         let newFont = UIFont(descriptor: fontDescriptor, size: fontSize)
         attributes[.font] = newFont
         
         let currentFrame = text.boundingRect(with: infiniteBounds, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
         
         if properBounds.contains(currentFrame) {
            bestFontSize = fontSize
            break
         }
      }
      return bestFontSize
   }
   
   static func bestFittingFont(for text: String, in bounds: CGRect, fontDescriptor: UIFontDescriptor, additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> UIFont {
      let bestSize = bestFittingFontSize(for: text, in: bounds, fontDescriptor: fontDescriptor, additionalAttributes: additionalAttributes)
      return UIFont(descriptor: fontDescriptor, size: bestSize)
   }
}
