//
//  Coordinator.swift
//  Track
//
//  Created by Marcus Rossel on 16.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Coordinator

/// A coordinator is a type used for navigating between and managing controllers.
protocol Coordinator {
   
   /// A coordinator uses a navigation controller to manage the displaying of content.
   var navigationController: UINavigationController { get }
   
   /// Causes control to be handed over to the coordinator.
   /// Usually this should cause the coordinator to push a basal view controller.
   func run()
}

// MARK: - Root Coordinator

/// A type of coordinator that can provide a view controller that serves as the app's root view
/// controller.
protocol RootCoordinator: Coordinator {
   
   var rootViewController: UIViewController { get }
}
