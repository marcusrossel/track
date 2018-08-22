//
//  TimerTabCoordinator.swift
//  Track
//
//  Created by Marcus Rossel on 18.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

final class TimerTabCoordinator: NSObject, Coordinator {
   
   private var hasRunBefore = false
   
   let navigationController = UINavigationController()
   
   private let categoryManager: Category.Manager
   private let trackManager: Track.Manager
   
   init(categoryManager: Category.Manager, trackManager: Track.Manager) {
      self.categoryManager = categoryManager
      self.trackManager = trackManager
      navigationController.isNavigationBarHidden = true
   }
   
   func run() {
      defer { hasRunBefore = true }
      guard !hasRunBefore else { return }
      
      let controller: UIViewController
      
      if let category = trackManager.runningCategory {
         controller = TimerController(delegate: self, category: category)
      } else {
         controller = CategorySelectionController(categories: categoryManager.categories)
      }

      navigationController.pushViewController(controller, animated: true)
   }
   
   #warning("Temporary")
   func testController() {
      let timeTracker = TimeTracker(startDate: Date())
      let controller = UIViewController()
      controller.view.backgroundColor = .white
      controller.view.addSubview(timeTracker)
      
      timeTracker.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
         timeTracker.heightAnchor.constraint(equalTo: controller.view.heightAnchor),
         timeTracker.widthAnchor.constraint(equalTo: controller.view.widthAnchor),
         timeTracker.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
         timeTracker.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor)
      ])
   }
}

extension TimerTabCoordinator: TimerControllerDelegate, UIPopoverPresentationControllerDelegate {
   
   func timerControllerDidStop(_ timerController: TimerController) {
      print("Stop")
   }
   
   func timerControllerDidSwitch(_ timerController: TimerController) {
      let categorySelecttionController = CategorySelectionController(
         categories: categoryManager.categories
      )
      
      let referencePoint = UIView()
      let position = CGPoint(
         x: timerController.switchButton.bounds.origin.x / 2,
         y: timerController.switchButton.bounds.origin.y / 2
      )
      referencePoint.frame = CGRect(origin: position, size: .zero)
      timerController.switchButton.addSubview(referencePoint)
      
      categorySelecttionController.modalPresentationStyle = .popover
      categorySelecttionController.popoverPresentationController?.delegate = self
      categorySelecttionController.popoverPresentationController?.sourceView = referencePoint
      
      navigationController.present(categorySelecttionController, animated: true, completion: nil)
   }
   
   // Makes sure a popover is presented as such.
   func adaptivePresentationStyle(for controller: UIPresentationController)
      -> UIModalPresentationStyle {
         return .none
   }
}
