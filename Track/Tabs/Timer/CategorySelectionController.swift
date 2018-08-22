//
//  CategorySelectionController.swift
//  Track
//
//  Created by Marcus Rossel on 20.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

class CategorySelectionController: UITableViewController {

   init(categories: [Category]) {
      super.init(nibName: nil, bundle: nil)
   }
   
   // MARK: - Requirements
   
   required init?(coder aDecoder: NSCoder) { fatalError("App does not use storyboard or XIB.") }
}
