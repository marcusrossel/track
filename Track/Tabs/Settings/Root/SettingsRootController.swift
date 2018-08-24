//
//  SettingsRootController.swift
//  Track
//
//  Created by Marcus Rossel on 16.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Settings Root Controller Delegate

protocol SettingsRootControllerDelegate {
   
   func didSelectCategories()
   func didSelectTags()
   
   func setupNavigationBar(for controller: SettingsRootController)
}

extension SettingsRootControllerDelegate {
   
   func setupNavigationBar(for controller: SettingsRootController) { }
}

// MARK: - Settings Root Controller

class SettingsRootController: UITableViewController {
   
   private var coordinator: SettingsRootControllerDelegate
   
   private var categoriesCell = UITableViewCell(style: .default, reuseIdentifier: nil)
   private var tagsCell = UITableViewCell(style: .default, reuseIdentifier: nil)
   
   private var cells: [UITableViewCell] {
      return [categoriesCell, tagsCell]
   }
   
   init(delegate: SettingsRootControllerDelegate) {
      // Phase 1.
      coordinator = delegate
      
      // Phase 2.
      super.init(style: .grouped)
      
      // Phase 3.
      tableView.isScrollEnabled = false
      tableView.rowHeight = .defaultHeight
      
      categoriesCell.textLabel?.text = "Categories"
      tagsCell.textLabel?.text = "Tags"
      
      categoriesCell.accessoryType = .disclosureIndicator
      tagsCell.accessoryType = .disclosureIndicator
      
      let imageLoader = ImageLoader()
      categoriesCell.imageView?.image = imageLoader[icon: .books]
      tagsCell.imageView?.image = imageLoader[icon: .tags]
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      coordinator.setupNavigationBar(for: self)
   }
   
   // MARK: - Requirements
   
   required init?(coder aDecoder: NSCoder) { fatalError("App does not use storyboard or XIB.") }
}

// MARK: - Layout

extension SettingsRootController {
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return cells.count
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let index = indexPath.row
      return cells[index]
   }
}

// MARK: - Coordination

extension SettingsRootController {
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let index = indexPath.row
      let selection = cells[index]
      
      switch selection {
      case categoriesCell: coordinator.didSelectCategories()
      case tagsCell:       coordinator.didSelectTags()
      default:             fatalError("Non exhaustive switch over variable domain.")
      }
   }
}
