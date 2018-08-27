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

   private let coordinator: TimerControllerDelegate
   
   private let titleLabel = UILabel()
   private let timeTracker = TimeTracker(startDate: Date(), fixedInterval: 0)
   private let playPauseButton = UIButton()
   private let stopButton = UIButton()
   let switchButton = UIButton()
   
   init(delegate: TimerControllerDelegate, category: Category) {
      // Phase 1.
      coordinator = delegate

      // Phase 2.
      super.init(nibName: nil, bundle: nil)
      
      // Phase 3.
      titleLabel.text = category.title
      // timeTracker = ?
      
      let imageLoader = ImageLoader()
      playPauseButton.setImage(imageLoader[button: .play], for: .normal)
      stopButton.setImage(imageLoader[button: .stop], for: .normal)
      switchButton.setImage(imageLoader[button: .switch], for: .normal)
      
      playPauseButton.addTarget(self, action: #selector(didPressPlayPause(_:)), for: .touchUpInside)
      stopButton.addTarget(self, action: #selector(didPressStop), for: .touchUpInside)
      switchButton.addTarget(self, action: #selector(didPressSwitch), for: .touchUpInside)
      
      view.backgroundColor = category.color
      
      setupLayoutConstraints()
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
      coordinator.timerControllerDidStop(self)
   }
   
   @objc private func didPressSwitch() {
      coordinator.timerControllerDidSwitch(self)
   }
}

// MARK: - Auto Layout

extension TimerController {
   
   private func setupLayoutConstraints() {
      let buttonStackView = UIStackView(arrangedSubviews: [
         playPauseButton, stopButton, switchButton
      ])
      buttonStackView.axis = .horizontal
      buttonStackView.alignment = .center
      buttonStackView.distribution = .fillEqually
      
      let enclosingStackView = UIStackView(arrangedSubviews: [
         titleLabel, timeTracker, buttonStackView
      ])
      enclosingStackView.axis = .vertical
      enclosingStackView.alignment = .center
      enclosingStackView.distribution = .fillEqually
      
      AutoLayoutHelper(rootView: view, viewToConstrain: enclosingStackView)
         .constrainView(generalInset: .defaultSpacing)
   }
}
