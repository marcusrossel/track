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
   private var timer = Timer()
   
   /// The label displaying the time.
   let timeLabel = UILabel()
   
   /// The starting point of the tracked interval.
   private var startDate = Date() { didSet { updateLabel() } }
   
   /// A fixed time interval to be shown, instead of the interval from the start date.
   private var fixedInterval: TimeInterval?
   
   /// The interval currently shown by the view.
   var interval: TimeInterval {
      get { return fixedInterval ?? Date().timeIntervalSince(startDate) }
      set {
         if fixedInterval != nil {
            fixedInterval = newValue
         } else {
            startDate = startDate(for: newValue)
         }
      }
   }
   
   /// Creates a timer from an initial interval and an option of starting in a paused state.
   /// If no interval is given, the timer will start at `0`.
   init(interval: TimeInterval = 0, isPaused: Bool = true) {
      // Phase 2.
      super.init(frame: .zero)
      
      // Phase 3.
      if isPaused {
         fixedInterval = interval
         updateLabel()
      } else {
         startDate = startDate(for: interval)
         timer = makeUpdateTimer()
      }
      
      // Sets up the view's layout constraints.
      setupTimeLabelFont()
      AutoLayoutHelper(rootView: self, viewToConstrain: timeLabel).constrainView()
   }
   
   /// A convenience method for getting a date that lies a given time interval in the past from now.
   private func startDate(for interval: TimeInterval) -> Date {
      return Date().addingTimeInterval(-interval)
   }
   
   /// A convenience method for styling the time label.
   private func setupTimeLabelFont() {
      timeLabel.textAlignment = .center
      let font = UIFont.systemFont(ofSize: 100)
      timeLabel.font = font
      timeLabel.adjustsFontSizeToFitWidth = true
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
   func pause() {
      fixedInterval = interval
      timer.invalidate()
   }
   
   /// Unfixes the timer from a set interval.
   func unpause() {
      guard let fixed = fixedInterval else { return }
      
      // Causes the start date to be adjusted, as to fit the previously fixed interval.
      startDate = startDate(for: fixed)
      fixedInterval = nil
      timer = makeUpdateTimer()
   }
   
   // MARK: - Requirements
   
   /// Do not call this initializer! This view does not support storyboards or XIB.
   required init?(coder aDecoder: NSCoder) { fatalError("View doesn't support storyboard or XIB.") }
}
