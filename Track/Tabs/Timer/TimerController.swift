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
   
   func setupNavigationBar(for controller: TimerController)
}

extension TimerControllerDelegate {
   
   func setupNavigationBar(for controller: TimerController) { }
}

final class TimerController: UIViewController {

   private var coordinator: TimerControllerDelegate?

   var track: Track {
      didSet {
         titleLabel.text = track.category.title
         timeTracker.track = track
         setState(tracking: track.isTracking)
      }
   }
   
   private let trackManager: Track.Manager
   
   private let titleLabel = UILabel()
   private let timeTracker: TimeTracker
   private let playPauseButton = UIButton()
   private let stopButton = UIButton()
   let switchButton = UIButton()
   
   init(category: Category, trackManager: Track.Manager, delegate: TimerControllerDelegate? = nil) {
      // Phase 1.
      coordinator = delegate
      self.trackManager = trackManager
      track = trackManager.todaysTrack(for: category) ?? trackManager.createTrack(for: category)!
      timeTracker = TimeTracker(track: track)
      
      // Phase 2.
      super.init(nibName: nil, bundle: nil)
      
      // Phase 3.
      setupTitleLabel()
      setupButtons()
      setState(tracking: track.isTracking)
      
      view.backgroundColor = .white
      
      setupLayoutConstraints()
   }
   
   private func setupTitleLabel() {
      titleLabel.text = track.category.title
      
      titleLabel.textAlignment = .center
      let font = UIFont.boldSystemFont(ofSize: 100)
      titleLabel.font = font
      titleLabel.adjustsFontSizeToFitWidth = true
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
   
   private func setState(tracking: Bool) {
      let imageLoader = ImageLoader()
      let buttonType: ImageLoader.Button = tracking ? .pause : .play
      
      playPauseButton.setImage(imageLoader[button: buttonType], for: .normal)
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      coordinator?.setupNavigationBar(for: self)
   }
   
   // MARK: - Requirements
   
   /// Do not call this initializer! This view does not support storyboards or XIB.
   required init?(coder aDecoder: NSCoder) { fatalError("View doesn't support storyboard or XIB.") }
}

// MARK: - Button Handling

extension TimerController {
   
   @objc private func didPressPlayPause(_ sender: UIButton) {
      let imageLoader = ImageLoader()
      switch track.isTracking {
      case true:
         playPauseButton.setImage(imageLoader[button: .play], for: .normal)
         if let trackOverflow = track.stop() {
            guard trackManager.addTracks(trackOverflow) else {
               fatalError("Undescribed error.")
            }
         }
         
      case false:
         playPauseButton.setImage(imageLoader[button: .pause], for: .normal)
         track.track()
      }
   }
   
   @objc private func didPressStop() {
      if let trackOverflow = track.stop() {
         guard trackManager.addTracks(trackOverflow) else {
            fatalError("Undescribed error.")
         }
      }
      
      coordinator?.timerControllerDidStop(self)
   }
   
   @objc private func didPressSwitch() {
      coordinator?.timerControllerDidSwitch(self)
   }
}

// MARK: - Auto Layout

extension TimerController {
   
   private func setupLayoutConstraints() {
      let buttonStackView = UIStackView(
         arrangedSubviews: [playPauseButton, stopButton, switchButton]
      )
      buttonStackView.axis = .horizontal
      buttonStackView.alignment = .bottom
      buttonStackView.distribution = .fillEqually
      
      let viewsToLayout = [titleLabel, timeTracker, buttonStackView]
      let guide = view.safeAreaLayoutGuide
      
      AutoLayoutHelper(rootView: view).setupViewsForAutoLayout(viewsToLayout)
      
      titleLabel.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
      titleLabel.setContentHuggingPriority(.required, for: .vertical)
      
      timeTracker.centerYAnchor.constraint(equalTo: guide.centerYAnchor).isActive = true
      
      buttonStackView.bottomAnchor.constraint(
         equalTo: guide.bottomAnchor, constant: 3 * -.defaultSpacing
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
