//
//  AutoLayoutHelper.swift
//  Track
//
//  Created by Marcus Rossel on 22.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

/// A helper for simple auto layout tasks.
final class AutoLayoutHelper {
   
   /// The view to which the views to layout should be subviews.
   let rootView: UIView
   
   /// The layout guide used when constraining views to the root view.
   let layoutGuide: UILayoutGuide
   
   /// The view to be constrained in `constrainView(withInset:)`.
   var viewToConstrain: UIView?
   
   /// Creates an auto layout helper instance working with the given parameters.
   /// If no layout guide is given, it defaults to the root view's safe area layout guide.
   init(rootView: UIView, viewToConstrain: UIView? = nil, layoutGuide: UILayoutGuide? = nil) {
      self.rootView = rootView
      self.viewToConstrain = viewToConstrain
      self.layoutGuide = layoutGuide ?? rootView.safeAreaLayoutGuide
   }
   
   /// Sets layout contraints between all sides of the view to constrain and the root view, at a
   /// given inset. By default the inset is `0`.
   /// If `viewToConstrain` is `nil`, nothing happens and `false` is returned.
   @discardableResult
   func constrainView(withInset inset: CGFloat = 0) -> Bool {
      guard let view = viewToConstrain else { return false }
      
      setupViewsForAutoLayout([view])
      
      let top = view.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: inset)
      let bottom = view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: inset)
      let leading = view.leadingAnchor.constraint(
         equalTo: layoutGuide.leadingAnchor, constant: inset
      )
      let trailing = view.trailingAnchor.constraint(
         equalTo: layoutGuide.trailingAnchor, constant: inset
      )
      
      NSLayoutConstraint.activate([top, bottom, leading, trailing])
      return true
   }
   
   /// Adds all given views as subviews of the root view, and sets
   /// `translatesAutoresizingMaskIntoConstraints` to `false`.
   func setupViewsForAutoLayout(_ views: [UIView]) {
      for view in views {
         view.translatesAutoresizingMaskIntoConstraints = false
         rootView.addSubview(view)
      }
   }
}
