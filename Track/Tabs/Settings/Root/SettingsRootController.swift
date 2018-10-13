//
//  SettingsRootController.swift
//  Track
//
//  Created by Marcus Rossel on 16.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Settings Root Controller

/// A view controller that shows and manages the list of all settings options.
final class SettingsRootController: UITableViewController {
   
   /// A delegate providing functionality external to a settings root controller.
   weak var delegate: SettingsRootControllerDelegate?
   
   /// The table view cell associated with the categories setting.
   private var categoriesCell: UITableViewCell = {
      let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
      
      // Sets up the table view cell.
      cell.textLabel?.text = "Categories"
      cell.imageView?.image = ImageLoader()[icon: .books]
      cell.accessoryType = .disclosureIndicator
      
      return cell
   }()
   
   /// Creates a settings root controller.
   init(delegate: SettingsRootControllerDelegate? = nil) {
      // Phase 1.
      self.delegate = delegate
      
      // Phase 2.
      super.init(style: .grouped)
      
      // Phase 3.
      tableView.isScrollEnabled = false
      tableView.rowHeight = .defaultHeight
   }
   
   // MARK: - Requirements
   
   /// Do not call this initializer! This view does not support storyboards or XIB.
   required init?(coder aDecoder: NSCoder) { fatalError("View doesn't support storyboard or XIB.") }
}

// MARK: - Table View Handeling

extension SettingsRootController {
   
   /// A type representing each setting shown by the settings root controller.
   private enum Setting: Int, CaseIterable {
      case categories
      
      /// Returns a key path to the the table view cell associated with the setting.
      var cellPath: KeyPath<SettingsRootController, UITableViewCell> {
         switch self {
         case .categories: return \.categoriesCell
         }
      }
   }
   
   /// A settings root controller has as many table view rows as `Setting`s.
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return Setting.allCases.count
   }
   
   /// Gets the table view cell at a given index path.
   override func tableView(
      _ tableView: UITableView, cellForRowAt indexPath: IndexPath
   ) -> UITableViewCell {
      // Converts the index path into a `Setting`.
      guard let setting = Setting(rawValue: indexPath.row) else {
         fatalError("Internal inconsistency in settings root controller.")
      }
      
      // Returns the table view cell associated with the requested setting.
      return self[keyPath: setting.cellPath]
   }
}

// MARK: - Coordination

extension SettingsRootController {
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      // Converts the index path into a `Setting`.
      guard let setting = Setting(rawValue: indexPath.row) else {
         fatalError("Internal inconsistency in settings root controller.")
      }
      
      // Calls the delegate method appropriate for the setting.
      switch setting {
      case .categories: delegate?.settingsRootControllerDidSelectCategories(self)
      }
   }
}

// MARK: - Settings Root Controller Delegate

/// A delegate providing functionality external to a settings root controller.
protocol SettingsRootControllerDelegate: AnyObject {
   
   func settingsRootControllerDidSelectCategories(_ settingsRootController: SettingsRootController)
}
