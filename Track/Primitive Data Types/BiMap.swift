//
//  BiMap.swift
//  Track
//
//  Created by Marcus Rossel on 18.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

/// A bijective map between key and value elements.
/// The type ensures O(1) subscripting in both directions.
struct BiMap<Key, Value> where Key: Hashable, Value: Hashable {
   
   // The dictionary from keys to values, allowing O(1) lookup of a value from a key.
   private var keysToValues: [Key: Value] = [:]
   
   // The dictionary from values to keys, allowing O(1) lookup of a key from a value.
   private var valuesToKeys: [Value: Key] = [:]
   
   // A collection exposing all of the keys in the map.
   var keys: Dictionary<Key, Value>.Keys {
      return keysToValues.keys
   }
   
   // A collection exposing all of the values in the map.
   var values: Dictionary<Key, Value>.Values {
      return keysToValues.values
   }
   
   /// Creates an empty bimap.
   ///
   /// Complexity: O(1)
   public init(uniqueBijectivePairs: [Key: Value] = [:]) {
      // Processes the key-value pairs.
      for (key, value) in uniqueBijectivePairs {
         // Performs precondition checks.
         guard
            !keysToValues.keys.contains(key) &&
            !keysToValues.values.contains(value)
         else {
            fatalError("Attempted to create a `Bimap` from non-unique key-value pairs.")
         }
         
         // Sets the dictionaries' key-value pairs.
         keysToValues[key] = value
         valuesToKeys[value] = key
      }
   }
   
   // Sets a given key-value pair.
   //
   // If either key or value are `nil`, the opposing key's or value's entry in the bimap is removed.
   //
   // If neither value is `nil`, a new key-value pair is set (if this would break the
   // bimap-invariant an error occurs).
   //
   // Complexity: O(1)
   private mutating func setPair(key: Key?, value: Value?) {
      // Determines what needs to be done for different types of key-value pairs.
      switch (key, value) {
         
      // For a `nil` key-value pair nothing needs to be done.
      case (nil, nil):
         return
         
      // Removes the key-value pair belonging to the given key from the bimap.
      case (let key?, nil):
         guard let valueForKey = keysToValues[key] else { return }
         keysToValues[key] = nil
         valuesToKeys[valueForKey] = nil
         
      // Removes the key-value pair belonging to the given value from the bimap.
      case (nil, let value?):
         guard let keyForValue = valuesToKeys[value] else { return }
         valuesToKeys[value] = nil
         keysToValues[keyForValue] = nil
         
      // Checks that the key-value pair does not break the bimap's invariant, and inserts it if
      // possible.
      case (let key?, let value?):
         // Precondition checks.
         guard
            !keysToValues.keys.contains(key) &&
               !keysToValues.values.contains(value) ||
               keysToValues[key] == value
            else {
               fatalError("Attempted to set non-unique key-value pair in a `BiMap`.")
         }
         
         // Inserts the key-value pair.
         keysToValues[key] = value
         valuesToKeys[value] = key
      }
   }
   
   /// A subscript to the bimap using a key.
   ///
   /// Complexity: O(1)
   subscript(_ key: Key) -> Value? {
      get { return keysToValues[key] }
      set(newValue) { setPair(key: key, value: newValue) }
   }
   
   /// A subscript to the bimap using a value.
   ///
   /// Complexity: O(1)
   subscript(_ value: Value) -> Key? {
      get { return valuesToKeys[value] }
      set(newKey) { setPair(key: newKey, value: value) }
   }
}

// MARK: - Hashable

extension BiMap: Hashable {
   
   // Two bimaps are equal iff all of their key-value pairs are equal.
   static func ==(left: BiMap, right: BiMap) -> Bool {
      return left.keysToValues == right.keysToValues
   }
   
   func hash(into hasher: inout Hasher) {
      hasher.combine(keysToValues)
   }
}

// MARK: - Codable

extension BiMap: Codable where Key: Codable, Value: Codable {
   
   func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(keysToValues)
   }
   
   init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      self.init(uniqueBijectivePairs: try container.decode([Key: Value].self))
   }
}

// MARK: - ExpressibleByDictionaryLiteral

extension BiMap: ExpressibleByDictionaryLiteral {
   
   /// Creates a bimap from a dictionary literal.
   /// The literal must only contain unique bijective key-value pairs, or else a runtime error
   /// occurs.
   ///
   /// Complexity: O(elements.count)
   public init(dictionaryLiteral elements: (Key, Value)...) {
      let dictionary = Dictionary(uniqueKeysWithValues: elements)
      self.init(uniqueBijectivePairs: dictionary)
   }
}

// MARK: - Sequence

extension BiMap: Sequence {
   
   /// The iterator used by a `BiMap` to generate its sequence.
   public typealias Iterator = Dictionary<Key, Value>.Iterator
   
   /// Creates the bimap's iterator.
   public func makeIterator() -> DictionaryIterator<Key, Value> {
      return keysToValues.makeIterator()
   }
}

// MARK: - Collection

extension BiMap: Collection {
   
   /// The type used by a `BiMap` to index it as a collection.
   public typealias Index = Dictionary<Key, Value>.Index
   
   /// The bimap's start index.
   public var startIndex: Index { return keysToValues.startIndex }
   
   /// The bimap's end index.
   public var endIndex: Index { return keysToValues.endIndex }
   
   /// Returns the element at a given index.
   public subscript(position: Index) -> Iterator.Element {
      return keysToValues[position]
   }
   
   /// Returns the index after a given index.
   public func index(after index: Index) -> Index {
      return keysToValues.index(after: index)
   }
}
