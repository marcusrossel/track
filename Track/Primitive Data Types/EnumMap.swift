//
//  EnumMap.swift
//  Track
//
//  Created by Marcus Rossel on 18.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

struct EnumMap<Enum, Value> where Enum: CaseIterable & Hashable {
   
   private(set) var dictionary: [Enum: Value]
   
   init?(dictionary: [Enum: Value]) {
      let cases = Set(dictionary.keys)
      let allCases = Set(Enum.allCases)
      
      guard cases == allCases else { return nil }
      
      self.dictionary = dictionary
   }
   
   init(valueMap: (Enum) -> Value) {
      let pairs = Enum.allCases.map { `case` in (`case`, valueMap(`case`)) }
      dictionary = Dictionary(uniqueKeysWithValues: pairs)
   }
   
   subscript(case: Enum) -> Value {
      get { return dictionary[`case`]! }
      set { dictionary[`case`] = newValue }
   }
}

extension EnumMap: Codable where Enum: Codable, Value: Codable { }

extension EnumMap: ExpressibleByDictionaryLiteral {
   
   init(dictionaryLiteral elements: (Enum, Value)...) {
      let dictionary = Dictionary(uniqueKeysWithValues: elements)
      self.init(dictionary: dictionary)!
   }
}
