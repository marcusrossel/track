//
//  Category.swift
//  Track
//
//  Created by Marcus Rossel on 17.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

final class Category {
   
   /// All instantiated instances of categories at the current point in time.
   private static var allInstances: Set<Category> = []
   
   // Checks if the given title is not empty, and no other category exists with the same title.
   private static func titleAllowsInstantiation(_ title: String) -> Bool {
      return !title.isEmpty && Category.allInstances.allSatisfy { $0.title != title }
   }
   
   /// A non-empty title that uniquely identifies a category.
   private(set) var title: String
   
   /// A color associated with a category, used when representing the category visually.
   var color: UIColor
   
   init?(title: String, color: UIColor) {
      guard Category.titleAllowsInstantiation(title) else { return nil }
      defer { Category.allInstances.insert(self) }
      
      // Sets the category's properties.
      self.title = title
      self.color = color
   }
   
   /// Changes the category's title to the given one, if no other category (in `allInstances`) has
   /// that title, and it is non-empty.
   func rename(to newTitle: String) -> Bool {
      guard Category.titleAllowsInstantiation(newTitle) else { return false }
      
      title = newTitle
      return true
   }
}

extension Category: Hashable {
   
   /// Categories are equal iff their titles are equal iff they are identical.
   static func ==(lhs: Category, rhs: Category) -> Bool {
      return lhs === rhs
   }
   
   func hash(into hasher: inout Hasher) {
      hasher.combine(ObjectIdentifier(self))
   }
}

extension Category: Codable {
   
   enum CodingKeys: CodingKey {
      case title
      case colorComponents
   }
   
   func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      
      try container.encode(title, forKey: .title)
      try container.encode(color.decomposed, forKey: .colorComponents)
   }
   
   convenience init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      
      let title = try container.decode(String.self, forKey: .title)
      let colorComponents = try container.decode(
         EnumMap<UIColor.Component, CGFloat>.self,
         forKey: .colorComponents
      )
      let color = UIColor(components: colorComponents.dictionary)
      
      self.init(title: title, color: color)!
   }
}
