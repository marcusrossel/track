//
//  Code Dump.swift
//  Track
//
//  Created by Marcus Rossel on 22.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Bug

/*
 
 >> Timer Controller:
  - Create a category with title X and color Y. Create a prototype with title X and color Z.
    Delete the category.
    Edit title of prototype -> Completion of editing will keep showing the type as prototype.
    Go back to settings root controller and open categories option again
    -> the prototype is gone, and there is again a category of title X and color Y.
*/

// MARK: - To Do

/*
 
 + Make better factories
 
 >> Timer Tab Coordinator:
  - Add navigation bar handler
  - Introduce a `State` enum with selecting and timing states (and perhaps others like transitioning
    with an associated value to pass information to the new state).
 
 >> Image Loader:
  - Make the methods static. Instantiation has seemed pointless so far.
 
 >> Timer Controller:
  - Introduce a `State` enum with tracking, idle and editing states
  - Add more fades and animations
  - add minor "Hour(s)"/"h", "Minute(s)"/"min" and "Second(s)"/"s" labels
  - show action sheet for 3 seconds, saying that you can not exceed todays time, when necessary
 
 >> Categories Controller:
  - Create a seperate prototypes section, when adding a new cell
  - Properly split up categories controller's responsibilities
 
*/

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
   
   init(hours: Int, minutes: Int, seconds: Int) {
      let totalMinutes = 60 * hours + minutes
      let totalSeconds = 60 * totalMinutes + seconds
      self.init(totalSeconds)
   }
   
   static func passedOfDay(atDate date: Date, accordingTo calendar: Calendar) -> TimeInterval {
      let (hours, minutes, seconds) = date.decomposed(accordingTo: calendar)
      return TimeInterval(hours: hours, minutes: minutes, seconds: seconds)
   }
}

extension Date {

   func decomposed(accordingTo calendar: Calendar) -> (hours: Int, minutes: Int, seconds: Int) {
      let components = Track.calendar.dateComponents([.hour, .minute, .second], from: self)
      
      guard
         let hours = components.hour,
         let minutes = components.minute,
         let seconds = components.second
      else {
         fatalError("Expected to be able to access given date components.")
      }
      
      return (hours, minutes, seconds)
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
   
   static func square(of length: CGFloat) -> CGSize {
      return CGSize(width: length, height: length)
   }
}

extension CGRect {

   var center: CGPoint { return CGPoint(x: midX, y: midY) }
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
   
   var decomposed: EnumMap<Component, CGFloat> {
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

   var luminosity: CGFloat {
      return [(Component.red, 0.2126), (.green, 0.7152), (.blue, 0.0722)]
         .reduce(0) { result, item in result + item.1 * pow(decomposed[item.0], 2.2) }
   }
   
   var isLight: Bool {
      return luminosity > 0.5
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

extension UINavigationBar {
   
   func setColorsToDefault() {
      isTranslucent = true
      barTintColor = nil
      tintColor = nil
      largeTitleTextAttributes = [.foregroundColor: UIColor.black]
      titleTextAttributes = [.foregroundColor: UIColor.black]
   }
}

// MARK: - Operators

func *(scalar: Int, size: CGSize) -> CGSize {
   return CGSize(width: CGFloat(scalar) * size.width, height: CGFloat(scalar) * size.height)
}
