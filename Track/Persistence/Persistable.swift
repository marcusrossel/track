//
//  Persistable.swift
//  Track
//
//  Created by Marcus Rossel on 17.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

/// A type P is persistable if there exists a corresponding type entity type E, such that P is the
/// modelled type of E.
///
/// Semantically `Persistable` is like a lesser form of `Codable`.
/// It implies encodability only via its entity type and decodability only up to its entity type.
protocol Persistable {
   
   associatedtype Entity: EntityType where Entity.ModelledType == Self
}

/// A co-protocol to `Persistable`.
/// An entity type E for a modelled type M encapsulates all of the information needed to persist M.
/// The information stored by E needs to be enough to re-instantiate the instance of M, by using
/// E and any other means necessary.
protocol EntityType: Codable {
   
   associatedtype ModelledType
   
   init(modelledType: ModelledType)
}
