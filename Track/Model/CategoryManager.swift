//
//  CategoryManager.swift
//  Track
//
//  Created by Marcus Rossel on 18.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

// MARK: - Category Manager

final class CategoryManager {
   
   private(set) var categories: [Category] = [] {
      didSet { notifyObservers { $0.categoryManagerDidChange(self) } }
   }
   
   private var observers: [ObjectIdentifier: AnyCategoryManagerObserver] = [:]
   
   init() { }
   
   init?(categories: [Category]) {
      for category in categories {
         guard !self.categories.contains(category) else { return nil }
         category.addObserver(self)
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
      
      newCategory.addObserver(self)
      categories.insert(newCategory, at: index)
      return true
   }
   
   func move(categoryAtIndex origin: Int, to destination: Int) {
      let category = categories.remove(at: origin)
      categories.insert(category, at: destination)
      
      notifyObservers { $0.categoryManagerDidChange(self) }
   }
   
   @discardableResult
   func removeCategory(with title: String) -> Bool {
      let hasTitle: (Category) -> Bool = { $0.title == title }
      guard let index = categories.firstIndex(where: hasTitle) else { return false }
      
      // Observer broadcast and category observation removal, is delegated to `remove(atIndex:)`.
      remove(atIndex: index)
      return true
   }
   
   func remove(atIndex index: Int) {
      let category = categories.remove(at: index)
      
      category.removeObserver(self)
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

// MARK: - Observation

extension CategoryManager {
   
   func addObserver(_ observer: CategoryManagerObserver) {
      observers[ObjectIdentifier(observer)] = AnyCategoryManagerObserver(observer)
   }
   
   func removeObserver(_ observer: CategoryManagerObserver) {
      observers[ObjectIdentifier(observer)] = nil
   }
   
   private func notifyObservers(with closure: (CategoryManagerObserver) -> ()) {
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

extension CategoryManager: CategoryObserver {
   
   /// Notifies the observers that the given category changed.
   func category(_ category: Category, didChangeTitleFrom oldTitle: String) {
      notifyObservers { $0.categoryManager(self, observedChangeInCategory: category) }
   }
   
   /// Notifies the observers that the given category changed.
   func categoryDidChangeColor(_ category: Category) {
      notifyObservers { $0.categoryManager(self, observedChangeInCategory: category) }
   }
}

// MARK: - Category Manager Observer

protocol CategoryManagerObserver: AnyObject {
   
   func categoryManager(_ categoryManager: CategoryManager, didRemoveCategory category: Category)
   
   func categoryManager(
      _ categoryManager: CategoryManager, observedChangeInCategory category: Category
   )
   
   func categoryManagerDidChange(_ categoryManager: CategoryManager)
}

/// A workaround for the missing ability of protocol existentials to conform to protocols.
final class AnyCategoryManagerObserver {
   private(set) weak var observer: CategoryManagerObserver?
   init(_ observer: CategoryManagerObserver) { self.observer = observer }
}
