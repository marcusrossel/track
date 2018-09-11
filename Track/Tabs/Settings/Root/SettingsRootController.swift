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
   
   func setupNavigationBar(for controller: SettingsRootController)
}

extension SettingsRootControllerDelegate {
   
   func setupNavigationBar(for controller: SettingsRootController) { }
}

// MARK: - Settings Root Controller

class SettingsRootController: UITableViewController {
   
   private enum Setting: Int, CaseIterable {
      case categories
      
      var cellPath: KeyPath<SettingsRootController, UITableViewCell> {
         switch self {
         case .categories: return \.categoriesCell
         }
      }
   }
   
   private var coordinator: SettingsRootControllerDelegate?
   
   private var categoriesCell = UITableViewCell(style: .default, reuseIdentifier: nil)
   
   init(delegate: SettingsRootControllerDelegate? = nil) {
      // Phase 1.
      coordinator = delegate
      
      // Phase 2.
      super.init(style: .grouped)
      
      // Phase 3.
      tableView.isScrollEnabled = false
      tableView.rowHeight = .defaultHeight
      
      categoriesCell.textLabel?.text = "Categories"
      
      categoriesCell.accessoryType = .disclosureIndicator
      
      let imageLoader = ImageLoader()
      categoriesCell.imageView?.image = imageLoader[icon: .books]
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      coordinator?.setupNavigationBar(for: self)
   }
   
   // MARK: - Requirements
   
   required init?(coder aDecoder: NSCoder) { fatalError("App does not use storyboard or XIB.") }
}

// MARK: - Layout

extension SettingsRootController {
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return Setting.allCases.count
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      guard let setting = Setting(rawValue: indexPath.row) else {
         fatalError("Internal inconsistency between number of settings and number of cells.")
      }
      return self[keyPath: setting.cellPath]
   }
}

// MARK: - Coordination

extension SettingsRootController {
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      switch Setting(rawValue: indexPath.row) {
      case .categories?: coordinator?.didSelectCategories()
      default:             fatalError("Non exhaustive switch over variable domain.")
      }
   }
}
