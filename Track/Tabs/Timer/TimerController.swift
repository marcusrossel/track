//
//  TimerController.swift
//  Track
//
//  Created by Marcus Rossel on 20.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

protocol TimerControllerDelegate {
   
   func timerController(_ timerController: TimerController, changedTrackTo track: Track)
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
         timeTracker.track = track
         adjustButtonState(tracking: trackManager.isRunning(track.category))
         coordinator?.timerController(self, changedTrackTo: track)
      }
   }
   
   private let trackManager: TrackManager
   private let categoryManager: CategoryManager
   
   private let timeTracker: TimeTracker
   private let playPauseButton = UIButton()
   private let stopButton = UIButton()
   let switchButton = UIButton()

   init(
      category: Category,
      trackManager: TrackManager,
      categoryManager: CategoryManager,
      delegate: TimerControllerDelegate? = nil
   ) {
      // Phase 1.
      coordinator = delegate
      self.trackManager = trackManager
      self.categoryManager = categoryManager
      
      track = trackManager.currentTrack(for: category)
      timeTracker = TimeTracker(track: track)
      
      // Phase 2.
      super.init(nibName: nil, bundle: nil)
      
      // Phase 3.
      view.backgroundColor = .white
      setupButtons()
      adjustButtonState(tracking: trackManager.isRunning(track.category))

      setupLayoutConstraints()
      
      coordinator?.timerController(self, changedTrackTo: track)
   }
   
   private func setupButtons() {
      let imageLoader = ImageLoader()
      
      let items: [(UIButton, ImageLoader.Button, Selector)] = [
         (playPauseButton, .play, #selector(didPressPlayPause)),
         (stopButton, .stop, #selector(didPressStop)),
         (switchButton, .switch, #selector(didPressSwitch))
      ]
         
      for item in items {
         let image = imageLoader[button: item.1]
         item.0.setImage(image, for: .normal)
         item.0.addTarget(self, action: item.2, for: .touchUpInside)
      }
   }
   
   private func adjustButtonState(tracking: Bool) {
      let imageLoader = ImageLoader(useDefaultSizes: false)
      let buttonType: ImageLoader.Button = tracking ? .pause : .play
      let size = CGSize(
         width: 2 * ImageLoader.Button.defaultSize.width,
         height: 2 * ImageLoader.Button.defaultSize.height
      )
      let image = imageLoader[button: buttonType].resizedKeepingAspect(forSize: size)
      
      playPauseButton.setImage(image, for: .normal)
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
   
   @objc private func didPressPlayPause() {
      adjustButtonState(tracking: !trackManager.isRunning(track.category))
      
      if trackManager.isRunning(track.category) {
         trackManager.stopRunning()
      } else {
         trackManager.setRunning(track.category)
      }
   }
   
   @objc private func didPressStop() {
      trackManager.stopRunning()
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
         arrangedSubviews: [stopButton, playPauseButton, switchButton]
      )
      buttonStackView.axis = .horizontal
      buttonStackView.alignment = .bottom
      buttonStackView.distribution = .fillProportionally

      let viewsToLayout = [timeTracker, buttonStackView]
      let guide = view.safeAreaLayoutGuide
      
      AutoLayoutHelper(rootView: view).setupViewsForAutoLayout(viewsToLayout)
      
      for viewToLayout in viewsToLayout {
         viewToLayout.leadingAnchor.constraint(
            equalTo: guide.leadingAnchor, constant: .defaultSpacing
            ).isActive = true
         
         viewToLayout.trailingAnchor.constraint(
            equalTo: guide.trailingAnchor, constant: -.defaultSpacing
            ).isActive = true
      }
      
      timeTracker.topAnchor.constraint(
         equalTo: guide.topAnchor, constant: 3 * .defaultSpacing
      ).isActive = true
      
      buttonStackView.bottomAnchor.constraint(
         equalTo: guide.bottomAnchor, constant: 3 * -.defaultSpacing
      ).isActive = true
   }
}
