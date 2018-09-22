//
//  PersistenceManager.swift
//  Track
//
//  Created by Marcus Rossel on 17.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

/// A manager for reading and writing to and from disk.
final class PersistenceManager {
   
   /// An item that can be persisted by the manager.
   enum Item: String {
      case categoryManager
   }
   
   enum ModelledItem: String {
      case trackManager
   }
   
   /// `NSError`-codes used by some of the manager's methods.
   private enum ErrorCode {
      static let wroteToNonExistentFile = 4
      static let readNonExistentFile = 260
   }
   
   /// The file manager used by the persistence manager.
   private let fileManager = FileManager.default
   
   /// The file type in which all files are stored by the manager.
   private let fileType = "json"
   
   /// The base directory in which all files are stored by the manager.
   /// As the files are user generated, the "documents" directory is used.
   private lazy var storageDirectory: URL = {
      do {
         return try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
         )
      }
      catch { fatalError("System was unable to retrieve default document directory URL.") }
   }()
   
   /// A convenience method for getting the storage path URL for a given persistence item.
   private func path(for item: Item) -> URL {
      return storageDirectory
         .appendingPathComponent(item.rawValue)
         .appendingPathExtension(fileType)
   }
   
   private func path(for item: ModelledItem) -> URL {
      return storageDirectory
         .appendingPathComponent(item.rawValue)
         .appendingPathExtension(fileType)
   }
   
   /// Persists a given encodable value for a given item.
   func write<T: Encodable>(_ item: Item, value: T) throws {
      try JSONEncoder()
         .encode(value)
         .write(to: path(for: item))
   }
   
   /// Persists a given persistable value for a given item.
   func write<T: Persistable>(_ item: ModelledItem, asEntityFor value: T) throws {
      let entity = T.Entity(modelledType: value)
      
      try JSONEncoder()
         .encode(entity)
         .write(to: path(for: item))
   }
   
   /// Tries to read a given item from disk, as a given type.
   /// The return value will be `nil` iff no file exists yet for the item.
   /// All other types of errors will be thrown.
   func read<T: Decodable>(_ item: Item, as type: T.Type) throws -> T? {
      let fileData: Data
      
      print(path(for: item))
      
      /// Catches the case of there being no file.
      do { fileData = try Data(contentsOf: path(for: item)) }
      catch let error as NSError where error.code == ErrorCode.readNonExistentFile { return nil }
      
      return try JSONDecoder().decode(type, from: fileData)
   }
   
   func read<T: Persistable>(_ item: ModelledItem, asEntityFor type: T.Type) throws -> T.Entity? {
      let fileData: Data
      
      print(path(for: item))
      
      /// Catches the case of there being no file.
      do { fileData = try Data(contentsOf: path(for: item)) }
      catch let error as NSError where error.code == ErrorCode.readNonExistentFile { return nil }
      
      return try JSONDecoder().decode(type.Entity.self, from: fileData)
   }
}
