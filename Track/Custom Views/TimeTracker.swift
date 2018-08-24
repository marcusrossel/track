//
//  TimeTracker.swift
//  Track
//
//  Created by Marcus Rossel on 20.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

/// A view keeping track of and displaying time.
final class TimeTracker: UIView {

   /// A timer firing every second to update the view.
   private var timer: Timer
   
   /// The label displaying the time.
   let timeLabel: UILabel
   
   /// The starting point of the tracked interval.
   private(set) var startDate: Date { didSet { updateLabel() } }
   
   /// A fixed time interval to be shown, instead of the interval from the start date.
   private(set) var fixedInterval: TimeInterval?
   
   /// The interval currently shown by the view.
   /// The fixed interval will be returned if one is set, otherwise the interval from the start
   /// date.
   var interval: TimeInterval {
      if let fixed = fixedInterval { return fixed }
      else { return Date().timeIntervalSince(startDate) }
   }
   
   /// Creates a timer from a start date and optionally a fixed interval.
   /// If a fixed interval is given, the timer will use it immediately.
   init(startDate: Date, fixedInterval: TimeInterval? = nil) {
      // Phase 1.
      timer = Timer()
      timeLabel = UILabel()
      self.startDate = startDate
      
      // Phase 2.
      super.init(frame: .zero)
      
      // Phase 3.
      if fixedInterval != nil {
         self.fixedInterval = fixedInterval
         // The label must be updated once manually, as no timer is being set.
         updateLabel()
      } else {
         timer = makeUpdateTimer()
      }
      
      // Sets up the view's layout constraints.
      setupTimeLabelFont()
      AutoLayoutHelper(rootView: self, viewToConstrain: timeLabel).constrainView()
   }
   
   private func setupTimeLabelFont() {
      let font = UIFont.boldSystemFont(ofSize: 70)
      timeLabel.font = font
   }
   
   /// A convenience method for creating a new timer that calls `updateLabel()` every second.
   private func makeUpdateTimer() -> Timer {
      return Timer.scheduledTimer(
         timeInterval: 1,
         target: self,
         selector: #selector(updateLabel),
         userInfo: nil,
         repeats: true
      )
   }
   
   /// A convenience method for getting a string for a time interval.
   private func textRepresentation(forInterval interval: TimeInterval) -> String {
      let (hours, minutes, seconds, _) = interval.decomposed
      return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
   }
   
   /// The method for updating the time label.
   @objc private func updateLabel() {
      timeLabel.text = textRepresentation(forInterval: interval)
   }
   
   /// Fixes the timer at the current interval.
   /// Unfixing it will cause the start date to be adjusted, as to fit the fixed interval upon
   /// continuation.
   func fixInterval() {
      fixedInterval = interval
      timer.invalidate()
   }
   
   /// Unfixes the timer from a set interval.
   /// This will cause the start date to be adjusted, as to fit the previously fixed interval.
   func unfixInterval() {
      guard let fixed = fixedInterval else { return }
      
      startDate = Date().addingTimeInterval(-fixed)
      fixedInterval = nil
      timer = makeUpdateTimer()
   }
   
   // MARK: - Requirements
   
   /// Do not call this initializer! This view does not support storyboards or XIB.
   required init?(coder aDecoder: NSCoder) { fatalError("View doesn't support storyboard or XIB.") }
}
