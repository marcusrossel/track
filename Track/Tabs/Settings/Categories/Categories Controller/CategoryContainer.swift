//
//  CategoryContainer.swift
//  Track
//
//  Created by Marcus Rossel on 07.10.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

extension Category {
   final class Prototype {
      
      let title: String
      let color: UIColor
      
      init(title: String = "", color: UIColor = .black) {
         self.title = title
         self.color = color
      }
   }
}

protocol CategoryContainer {
   
   var title: String { get }
   var color: UIColor { get }
}

extension Category: CategoryContainer { }
extension Category.Prototype: CategoryContainer { }
