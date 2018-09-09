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
   
   /// The edges being constrained by the auto layout helper.
   enum Edge {
      case top(inset: CGFloat)
      case bottom(inset: CGFloat)
      case leading(inset: CGFloat)
      case trailing(inset: CGFloat)
      
      /// All cases of edges with an inset of `0`.
      static let allCases: [Edge] = [
         .top(inset: 0), .bottom(inset: 0), .leading(inset: 0), .trailing(inset: 0)
      ]
      
      /// A getter for the edge's inset.
      fileprivate var inset: CGFloat {
         switch self {
         case .top(inset: let inset), .bottom(inset: let inset),
              .leading(inset: let inset), .trailing(inset: let inset):
            return inset
         }
      }
      
      /// A multiplier that determines in which direction an inset needs to be added for each edge.
      fileprivate var insetMultiplier: CGFloat {
         switch self {
         case .top, .leading: return 1
         case .bottom, .trailing: return -1
         }
      }
      
      /// An "Either"-type for the anchors the can be associated with an edge.
      fileprivate enum Anchor {
         case xAxis(NSLayoutXAxisAnchor)
         case yAxis(NSLayoutYAxisAnchor)
      }
      
      /// Gets the anchor associated with an edge of a given view.
      fileprivate func anchor(for view: UIView) -> Anchor {
         switch self {
         case .top: return .yAxis(view.topAnchor)
         case .bottom: return .yAxis(view.bottomAnchor)
         case .leading: return .xAxis(view.leadingAnchor)
         case .trailing: return .xAxis(view.trailingAnchor)
         }
      }
      
      /// Gets the anchor associated with an edge of a given layout guide.
      fileprivate func anchor(for layoutGuide: UILayoutGuide) -> Anchor {
         switch self {
         case .top: return .yAxis(layoutGuide.topAnchor)
         case .bottom: return .yAxis(layoutGuide.bottomAnchor)
         case .leading: return .xAxis(layoutGuide.leadingAnchor)
         case .trailing: return .xAxis(layoutGuide.trailingAnchor)
         }
      }
   }
   
   /// The view to which the views to layout should be subviews.
   let rootView: UIView
   
   /// The view to be constrained in `constrainView(withInset:)`.
   var viewToConstrain: UIView?

   init(rootView: UIView, viewToConstrain: UIView? = nil) {
      self.rootView = rootView
      self.viewToConstrain = viewToConstrain
   }
   
   /// Sets layout contraints between all specified edges of the view to constrain and the root
   /// view, at given insets. By default the general inset and the edges' insets are `0`.
   /// If `viewToConstrain` is `nil`, nothing happens and `false` is returned.
   @discardableResult
   func constrainView(
      generalInset: CGFloat = 0,
      including included: [Edge] = Edge.allCases
   ) -> Bool {
      // Aborts if there is no view to constrain.
      guard let view = viewToConstrain else { return false }
      
      setupViewsForAutoLayout([view])
      
      // Adds the constraints for all included edges.
      for edge in included {
         let inset = edge.insetMultiplier * (edge.inset + generalInset)
         
         // Adds the constraint between view to constrain and layout guide.
         switch (edge.anchor(for: view), edge.anchor(for: rootView.safeAreaLayoutGuide)) {
         case let (.xAxis(first), .xAxis(second)):
            first.constraint(equalTo: second, constant: inset).isActive = true
         case let (.yAxis(first), .yAxis(second)):
            first.constraint(equalTo: second, constant: inset).isActive = true
         default:
            fatalError("Internal inconsistency in `anchor(for:)` methods.")
         }
      }
      
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
