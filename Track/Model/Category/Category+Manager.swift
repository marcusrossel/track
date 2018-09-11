//
//  Category.swift
//  Track
//
//  Created by Marcus Rossel on 17.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Category

final class Category {
   
   typealias ID = UUID
   
   let id: ID
   fileprivate(set) var title: String
   var color: UIColor
   
   init(title: String, color: UIColor = .black, id: ID = ID()) {
      self.title = title
      self.color = color
      self.id = id
   }
}

// MARK: - Conformances

extension Category: Equatable, Hashable {
   
   static func ==(lhs: Category, rhs: Category) -> Bool {
      return lhs.title == rhs.title
   }
   
   func hash(into hasher: inout Hasher) {
      hasher.combine(id)
   }
}

extension Category: Codable {
   
   enum CodingKeys: String, CodingKey {
      case id
      case title
      case rgba
   }
   
   func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      
      try container.encode(id, forKey: .id)
      try container.encode(title, forKey: .title)
      try container.encode(color.decomposed, forKey: .rgba)
   }
   
   convenience init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      
      let id = try container.decode(ID.self, forKey: .id)
      let title = try container.decode(String.self, forKey: .title)
      
      let rgba = try container.decode([UIColor.Component: CGFloat].self, forKey: .rgba)
      let color = UIColor(components: rgba)
      
      self.init(title: title, color: color, id: id)
   }
}

// MARK: - Category Manager

extension Category {
   
   final class Manager {
      
      private(set) var categories: [Category] = []
      
      init() { }
      
      init?(categories: [Category]) {
         self.categories = []
         
         for category in categories {
            guard !category.title.isEmpty && !self.categories.contains(category)
               else { return nil }
            
            self.categories.append(category)
         }
      }
      
      func uniqueCategory(with id: Category.ID) -> Category? {
         return categories.first { $0.id == id }
      }
      
      func uniqueCategory(with title: String) -> Category? {
         return categories.first { $0.title == title }
      }
      
      func uniqueCategory(where condition: (Category) -> Bool) -> Category? {
         let satisfiers = categories.filter(condition)
         guard satisfiers.count == 1 else { return nil }
         return satisfiers.first
      }
      
      func rename(category: Category, to title: String) -> Bool {
         guard !title.isEmpty else { return false }
         
         if let categoryForTitle = uniqueCategory(with: title), categoryForTitle !== category {
            return false
         }
         
         category.title = title
         return true
      }
      
      func insert(_ category: Category, atIndex index: Int) -> Bool {
         guard !category.title.isEmpty && !categories.contains(category) else { return false }
         
         categories.insert(category, at: index)
         return true
      }
      
      func move(categoryAtIndex origin: Int, to destination: Int) {
         let category = categories.remove(at: origin)
         
         if destination == categories.count {
            categories.append(category)
         } else {
            categories.insert(category, at: destination)
         }
      }
      
      @discardableResult
      func removeCategory(with title: String) -> Bool {
         guard let index = categories.firstIndex(where: { $0.title == title }) else { return false }
         
         categories.remove(at: index)
         return true
      }
      
      func remove(atIndex index: Int) {
         categories.remove(at: index)
      }
   }
}
