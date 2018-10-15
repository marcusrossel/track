//
//  Category.swift
//  Track
//
//  Created by Marcus Rossel on 17.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Category

final class Category {

   /// All instantiated instances of categories at the current point in time.
   private static var allInstances: Set<Weak<Category>> = []
   
   // Checks if the given title is not empty, and no other category exists with the same title.
   private static func titleAllowsInstantiation(_ title: String) -> Bool {
      // Shortcuts if the title is empty.
      guard !title.isEmpty else { return false }
      
      // Determines whether there already exists a category of the given title, while also removing
      // those `Weak`-containers from `allInstances`, whose objects have been deallocated.
      let titleIsUnique = Category.allInstances.reduce(true) { uniquenessStatus, nextCategory in
         guard let category = nextCategory.object else { return uniquenessStatus }
         return uniquenessStatus && category.title != title
      }
      
      return titleIsUnique
   }
   
   /// A non-empty title that uniquely identifies a category.
   private(set) var title: String {
      didSet { notifyObservers { $0.category(self, didChangeTitleFrom: oldValue) } }
   }
   
   /// A color associated with a category, used when representing the category visually.
   var color: UIColor {
      didSet { notifyObservers { $0.categoryDidChangeColor(self) } }
   }
   
   /// The container storing the instances observing the category.
   private var observers: [ObjectIdentifier: AnyCategoryObserver] = [:]

   init?(title: String, color: UIColor) {
      guard Category.titleAllowsInstantiation(title) else { return nil }
      defer { Category.allInstances.insert(Weak(self)) }
      
      // Sets the category's properties.
      self.title = title
      self.color = color
   }
   
   // MARK: - Logging

   #warning("Logging.")
   deinit {
      print("Deinialized category \"\(title)\".")
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

// MARK: - Observation

extension Category {
   
   func addObserver(_ observer: CategoryObserver) {
      observers[ObjectIdentifier(observer)] = AnyCategoryObserver(observer)
   }
   
   func removeObserver(_ observer: CategoryObserver) {
      observers[ObjectIdentifier(observer)] = nil
   }
   
   private func notifyObservers(with closure: (CategoryObserver) -> ()) {
      for (id, typeErasedWrapper) in observers {
         if let observer = typeErasedWrapper.observer {
            closure(observer)
         } else {
            observers[id] = nil
         }
      }
   }
   
}

// MARK: - Category Observer

protocol CategoryObserver: AnyObject {
   
   func category(_ category: Category, didChangeTitleFrom oldTitle: String)
   
   func categoryDidChangeColor(_ category: Category)
}

/// A workaround for the missing ability of protocol existentials to conform to protocols.
final class AnyCategoryObserver {
   private(set) weak var observer: CategoryObserver?
   init(_ observer: CategoryObserver) { self.observer = observer }
}
