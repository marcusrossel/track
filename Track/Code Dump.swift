//
//  Code Dump.swift
//  Track
//
//  Created by Marcus Rossel on 22.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Extensions

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

extension CGRect {
   
   var center: CGPoint {
      let centerX = origin.x + size.width / 2
      let centerY = origin.y + size.height / 2
      
      return CGPoint(x: centerX, y: centerY)
   }
}

extension UIView {
   
   func setShadow(radius: CGFloat = 8, opacity: Float = 0.5, offset: CGSize = .zero) {
      layer.shadowRadius = radius
      layer.shadowOpacity = opacity
      layer.shadowOffset = offset
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


// MARK: - Trash

#warning("Temporary")
class Track { }
extension Track {
   final class Manager {
      var runningCategory: Category? {
         return Category(title: "Category Title", color: .white)
      }
   }
}

final class _Track: Codable {
   var start: Date
   var end: Date?
   var categoryID: Category.ID
}

final class _TrackManager {
   
   private(set) var tracks: [_Track] = []
   
   var runningTrack: _Track? {
      return tracks.first { $0.end == nil }
   }
   
}

func _textColor(contrasting background: UIColor, whitePreferenceModifier: CGFloat = 10)
-> UIColor {
   let luminosity: (UIColor) -> CGFloat = {
      0.2126 * pow($0.decomposed[.red]!, 2.2) +
      0.7152 * pow($0.decomposed[.green]!, 2.2) +
      0.0722 * pow($0.decomposed[.blue]!, 2.2)
   }
      
   let luminosityDifference: (UIColor, UIColor) -> CGFloat = {
      let luminosities = [$0, $1].map(luminosity).sorted()
      return (luminosities[1] + 0.05) / (luminosities[0] + 0.05)
   }
      
   let deltaBlack = luminosityDifference(background, .black)
   let deltaWhite = luminosityDifference(background, .white) + whitePreferenceModifier
      
   return (deltaBlack > deltaWhite) ? .black : .white
}
