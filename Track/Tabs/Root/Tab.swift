//
//  Tab.swift
//  Track
//
//  Created by Marcus Rossel on 16.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

/// The type encapsulating all of the information about the tabs shown by the tab coordinator.
enum Tab: Int, CaseIterable {
   case timer
   case today
   case record
   case settings
   
   var title: String {
      switch self {
      case .timer: return "Timer"
      case .today: return "Today"
      case .record: return "Record"
      case .settings: return "Settings"
      }
   }
   
   var icon: UIImage {
      let imageLoader = ImageLoader()
      let iconType: ImageLoader.Icon
      
      switch self {
      case .timer: iconType = .timer
      case .today: iconType = .today
      case .record: iconType = .record
      case .settings: iconType = .settings
      }
      
      return imageLoader[icon: iconType]
   }
}
