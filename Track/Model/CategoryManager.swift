//
//  CategoryManager.swift
//  Track
//
//  Created by Marcus Rossel on 18.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

// MARK: - Category Manager

final class CategoryManager: Broadcaster {
   
   private(set) var categories: [Category] = [] {
      didSet { notifyObservers { $0.categoryManagerDidChange(self) } }
   }
   
   var observers: [ObjectIdentifier: Weak<AnyCategoryManagerObserver>] = [:]
   
   init() { }
   
   init?(categories: [Category]) {
      for category in categories {
         guard !self.categories.contains(category) else { return nil }
         self.categories.append(category)
      }
   }
   
   /// Returns the only category with the given title stored by the manager.
   /// If none exists `nil` is returned.
   func uniqueCategory(with title: String) -> Category? {
      return categories.first { $0.title == title }
   }
   
   func insert(_ newCategory: Category, atIndex index: Int) -> Bool {
      guard !categories.contains(newCategory) else { return false }
      
      categories.insert(newCategory, at: index)
      return true
   }
   
   func move(categoryAtIndex origin: Int, to destination: Int) {
      let destinationIsEnd = destination == (categories.count - 1)
      let category = categories.remove(at: origin)
      
      if destinationIsEnd {
         categories.append(category)
      } else {
         categories.insert(category, at: destination)
      }
   }
   
   @discardableResult
   func removeCategory(with title: String) -> Bool {
      let hasTitle: (Category) -> Bool = { $0.title == title }
      guard let index = categories.firstIndex(where: hasTitle) else { return false }
      
      // Observer broadcast is delegated to `remove(atIndex:)`.
      remove(atIndex: index)
      return true
   }
   
   func remove(atIndex index: Int) {
      let category = categories.remove(at: index)
      notifyObservers { $0.categoryManager(self, didRemoveCategory: category) }
   }
}

// MARK: - Codable

extension CategoryManager: Codable {
   
   func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(categories)
   }
   
   convenience init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let categories = try container.decode([Category].self)
      self.init(categories: categories)!
   }
}

// MARK: - Category Manager Observer

protocol CategoryManagerObserver: ObserverType {
   
   func categoryManager(_ categoryManager: CategoryManager, didRemoveCategory category: Category)
   func categoryManagerDidChange(_ categoryManager: CategoryManager)
}

extension CategoryManagerObserver {
   
   func categoryManager(_ categoryManager: CategoryManager, didRemoveCategory category: Category) { }
   func categoryManagerDidChange(_ categoryManager: CategoryManager) { }
}

/// A workaround for the missing ability of protocol existentials to conform to protocols.
final class AnyCategoryManagerObserver: CategoryManagerObserver {
   
   private let observer: CategoryManagerObserver
   
   init(_ observer: CategoryManagerObserver) {
      self.observer = observer
   }
   
   func categoryManager(_ categoryManager: CategoryManager, didRemoveCategory category: Category) {
      observer.categoryManager(categoryManager, didRemoveCategory: category)
   }
   
   func categoryManagerDidChange(_ categoryManager: CategoryManager) {
      observer.categoryManagerDidChange(categoryManager)
   }
}
