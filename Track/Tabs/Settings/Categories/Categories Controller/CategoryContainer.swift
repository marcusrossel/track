//
//  CategoryContainer.swift
//  Track
//
//  Created by Marcus Rossel on 13.10.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

/// A container holding either a category, or the information needed to construct a category.
enum CategoryContainer {
   case category(Category)
   case prototype(title: String, color: UIColor)
}
