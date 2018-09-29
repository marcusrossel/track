//
//  ImageLoader.swift
//  Track
//
//  Created by Marcus Rossel on 24.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

/// A interface for the app's image assets.
final class ImageLoader {
   
   /// Indicates whether or not images should be resized to the default size for their type.
   private let useDefaultSizes: Bool
   
   /// Creates an image loader.
   /// Specifying `useDefaultSizes` as `true` will cause any loaded images to be resized to the
   /// default size for their respective type.
   init(useDefaultSizes: Bool = true) {
      self.useDefaultSizes = useDefaultSizes
   }
   
   /// Icons images will be loaded at a default size of 30 points.
   enum Icon: String {
      
      /// The default size for images of this type.
      static let defaultSize = CGSize(width: 30, height: 30)
      
      case bookStack = "book stack"
      case books
      case record
      case settings
      case tags
      case timer
      case today
   }
   
   /// Icons images will be loaded at a default size of 60 points.
   enum Button: String {
      
      /// The default size for images of this type.
      static let defaultSize = CGSize(width: 60, height: 60)
      
      case accept
      case add
      case cancel
      case confirmEdit = "confirm edit"
      case editTime = "edit time"
      case home
      case minus
      case pause
      case play
      case stop
      case `switch`
   }
   
   /// A convenience method that loads an image, given the type of the image and the raw value of
   /// its case.
   private func image<T>(forType type: T.Type, withRawValue rawValue: String) -> UIImage {
      var imageName = (rawValue as NSString).capitalized
      let defaultSize: CGSize
      
      // Sets up parameters depending on the image type.
      switch type {
      case _ where type == Icon.self:
         imageName += " Icon"
         defaultSize = Icon.defaultSize
         
      case _ where type == Button.self:
         imageName += " Button"
         defaultSize = Button.defaultSize
         
      default: fatalError("Non exhaustive switch over variable domain.")
      }
      
      // Loads the image from the asset catalogue.
      guard let image = UIImage(named: imageName) else {
         fatalError("Internal inconsistency between image loader and asset catalogue.")
      }
      
      // Returns the resized version of the loaded image, if appropriate.
      return (useDefaultSizes ? image.resizedKeepingAspect(forSize: defaultSize) : image)
   }
   
   /// Loads an icon-type image.
   subscript(icon icon: Icon) -> UIImage {
      return image(forType: Icon.self, withRawValue: icon.rawValue)
   }
   
   /// Loads a button-type image.
   subscript(button button: Button) -> UIImage {
      return image(forType: Button.self, withRawValue: button.rawValue)
   }
}
