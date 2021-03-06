//
//  TimeTracker.swift
//  Track
//
//  Created by Marcus Rossel on 20.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

#warning("Broken.")

/// A view keeping track of and displaying time.
final class TimeTracker: UIView {

   /// A timer firing every second to update the view.
   private var timer = Timer()
   
   /// The label displaying the time.
   let timeLabel = UILabel()
   
   var track: Track {
      didSet {
         updateLabel()
         timer = makeUpdateTimer()
      }
   }
   
   /// Creates a timer from an initial interval and an option of starting in a paused state.
   /// If no interval is given, the timer will start at `0`.
   init(track: Track) {
      // Phase 1.
      self.track = track
      
      // Phase 2.
      super.init(frame: .zero)
      
      // Phase 3.
      updateLabel()
      timer = makeUpdateTimer()
      setupTimeLabelFont()
      AutoLayoutHelper(rootView: self, viewToConstrain: timeLabel).constrainView()
   }

   /// A convenience method for styling the time label.
   private func setupTimeLabelFont() {
      timeLabel.textAlignment = .center
      timeLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 100)
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
      timeLabel.text = textRepresentation(forInterval: track.duration)
   }

   // MARK: - Requirements
   
   /// Do not call this initializer! This view does not support storyboards or XIB.
   required init?(coder aDecoder: NSCoder) { fatalError("View doesn't support storyboard or XIB.") }
}
