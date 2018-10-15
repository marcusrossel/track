//
//  CategoryConvertible.swift
//  Track
//
//  Created by Marcus Rossel on 07.10.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Category Convertible

/// A type that holds all of the information needed to construct a category.
protocol CategoryConvertible: AnyObject {
   
   var title: String { get }
   var color: UIColor { get set }
}

extension Category: CategoryConvertible { }

// MARK: - Category Prototype

extension Category {
   /// A minimal category convertible type used for building categories. A category prototype may
   /// contain values, that do not allow for the instantiation of a category.
   final class Prototype: CategoryConvertible {
      
      /// A potentially valid title for a category.
      var title: String
      
      /// A color for a category.
      var color: UIColor
      
      /// Creates a category prototype - by default with empty title and black color.
      init(title: String = "", color: UIColor = .black) {
         self.title = title
         self.color = color
      }
   }
}
