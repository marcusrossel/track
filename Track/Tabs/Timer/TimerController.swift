//
//  TimerController.swift
//  Track
//
//  Created by Marcus Rossel on 20.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

protocol TimerControllerDelegate {
   
   func timerControllerDidStop(_ timerController: TimerController)
   func timerControllerDidSwitch(_ timerController: TimerController)
}

final class TimerController: UIViewController {

   private var coordinator: TimerControllerDelegate?

   var category: Category {
      didSet {
         setupTitleLabel()
         setupTimeTracker()
      }
   }
   private let trackManager: Track.Manager
   
   private let titleLabel = UILabel()
   private let timeTracker = TimeTracker()
   private let playPauseButton = UIButton()
   private let stopButton = UIButton()
   let switchButton = UIButton()
   
   init(category: Category, trackManager: Track.Manager, delegate: TimerControllerDelegate? = nil) {
      // Phase 1.
      coordinator = delegate
      self.category = category
      self.trackManager = trackManager

      // Phase 2.
      super.init(nibName: nil, bundle: nil)
      
      // Phase 3.
      
      setupTitleLabel()
      setupTimeTracker()
      setupButtons()
      
      view.backgroundColor = .white
      
      setupLayoutConstraints()
   }
   
   private func setupTitleLabel() {
      titleLabel.text = category.title
      
      titleLabel.textAlignment = .center
      let font = UIFont.boldSystemFont(ofSize: 200)
      titleLabel.font = font
      titleLabel.adjustsFontSizeToFitWidth = true
   }
   
   private func setupTimeTracker() {
      if let track = trackManager.todaysTrack(for: category) {
         timeTracker.interval = track.interval
      } else {
         trackManager.createTrack(for: category)
         timeTracker.interval = 0
      }
   }
   
   private func setupButtons() {
      let imageLoader = ImageLoader()
      playPauseButton.setImage(imageLoader[button: .play], for: .normal)
      stopButton.setImage(imageLoader[button: .stop], for: .normal)
      switchButton.setImage(imageLoader[button: .switch], for: .normal)
      
      playPauseButton.addTarget(self, action: #selector(didPressPlayPause(_:)), for: .touchUpInside)
      stopButton.addTarget(self, action: #selector(didPressStop), for: .touchUpInside)
      switchButton.addTarget(self, action: #selector(didPressSwitch), for: .touchUpInside)
      
   }
   
   // MARK: - Requirements
   
   required init?(coder aDecoder: NSCoder) { fatalError("App does not use storyboard or XIB.") }
   
   // Pressing the stop button calls the coordinator.
   // the coordinator then pops the timercontroller and displays a categoryselection controller.
   
   // the categoryselectioncontroller shows a list of categories with the amount of time associated
   // with them today.
   // the categoryselectioncontroller has a delegate method that indicated that a category was
   // selected.
   
   // pressing the switch button causes the categoryselectioncontroller to be shown in a popover.
}

// MARK: - Button Handling

extension TimerController {
   
   @objc private func didPressPlayPause(_ sender: UIButton) {
      print("Play/Pause")
   }
   
   @objc private func didPressStop() {
      coordinator?.timerControllerDidStop(self)
   }
   
   @objc private func didPressSwitch() {
      coordinator?.timerControllerDidSwitch(self)
   }
}

// MARK: - Auto Layout

extension TimerController {
   
   private func setupLayoutConstraints() {
      let buttonStackView = UIStackView(arrangedSubviews: [
         playPauseButton, stopButton, switchButton
      ])
      buttonStackView.axis = .horizontal
      buttonStackView.alignment = .bottom
      buttonStackView.distribution = .fillEqually
      
      let viewsToLayout = [titleLabel, timeTracker, buttonStackView]
      let guide = view.safeAreaLayoutGuide
      
      AutoLayoutHelper(rootView: view).setupViewsForAutoLayout(viewsToLayout)
      
      titleLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: .defaultSpacing)
         .isActive = true
      
      timeTracker.centerYAnchor.constraint(equalTo: guide.centerYAnchor).isActive = true
      
      buttonStackView.bottomAnchor.constraint(
         equalTo: guide.bottomAnchor, constant: -.defaultSpacing
      ).isActive = true
      
      for viewToLayout in viewsToLayout {
         viewToLayout.leadingAnchor.constraint(
            equalTo: guide.leadingAnchor, constant: .defaultSpacing
         ).isActive = true
         
         viewToLayout.trailingAnchor.constraint(
            equalTo: guide.trailingAnchor, constant: -.defaultSpacing
         ).isActive = true
      }
   }
}
