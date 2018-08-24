//
//  PopoverHandler.swift
//  Track
//
//  Created by Marcus Rossel on 24.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

/// A handler for presenting view controllers as popover.
final class PopoverHandler: NSObject, UIPopoverPresentationControllerDelegate {
   
   /// The controller to be presented in the popover.
   private let presentedController: UIViewController
   
   /// A closure that will be called when the popover is dismissed.
   private let callback: (() -> ())?
   
   /// Creates a popover handler from the controller to present, a point at which the popover's
   /// anchor should be placed, and an optional closure to be called when the popover is dismissed.
   init(
      presentedController: UIViewController,
      sourceView: UIView,
      callback: (() -> ())? = nil
   ) {
      // Phase 1.
      self.presentedController = presentedController
      self.callback = callback
      
      // Phase 2.
      super.init()
      
      // Phase 3.
      presentedController.modalPresentationStyle = .popover
      
      let popoverController = presentedController.popoverPresentationController
      popoverController?.delegate = self
      popoverController?.sourceView = sourceView
      popoverController?.sourceRect = CGRect(origin: sourceView.bounds.center, size: .zero)
   }
   
   /// Presents the handler's `presentedController` in the given view controller.
   func present(
      in navigationController: UIViewController,
      animated: Bool = true,
      completion: (() -> ())? = nil
   ) {
      navigationController.present(presentedController, animated: animated, completion: completion)
   }

   /// The delegate method that assures that the presentation acutally occurs as a popover.
   func adaptivePresentationStyle(for controller: UIPresentationController)
   -> UIModalPresentationStyle {
      return .none
   }
   
   /// The delegate method used to call the callback if any was specified.
   func popoverPresentationControllerDidDismissPopover(
      _ popoverPresentationController: UIPopoverPresentationController
   ) {
      callback?()
   }
}
