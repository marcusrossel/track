//
//  TimerController.swift
//  Track
//
//  Created by Marcus Rossel on 20.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Timer Controller

/// A view controller that displays the current track state for a given category.
/// Additionally the controller provides means of changing a category's track state, manipulating
/// the tracked amount of time, as well as an interface for switching to another category.
final class TimerController: UIViewController {

   /// A type providing data needed for the controller to function.
   private var dataSource: TimerControllerDataSource
   
   /// A delegate providing functionality external to the timer controller.
   private var delegate: TimerControllerDelegate?

   /// The category whose track is currently being managed by the controller.
   var category: Category {
      didSet {
         setTimePickerDuration()
         
         let categoryIsRunning = dataSource.categoryIsRunning(category)
         updateForTrackingState(running: categoryIsRunning)
      
         delegate?.timerController(self, switchedToCategory: category)
      }
   }
   
   /// An indicater for whether the time picker is currently in editing mode or not.
   var isEditingDuration: Bool {
      return timePicker.isEditing
   }
   
   /// A timer used to continuously update the timer controller's state.
   private var updateTimer = Timer()
   
   /// The view displaying the category's track's duration.
   private let timePicker = TimePicker()
   
   /// The button used to run the category's track.
   private let playButton = UIButton()
   
   /// The button used to stop the category's track.
   private let pauseButton = UIButton()
   
   /// The button used to stop tracking the current category.
   private let stopButton = UIButton()
   
   /// The button used to dynamically switch between the category being tracked.
   let switchButton = UIButton()

   /// Creates a timer controller.
   init(
      category: Category,
      dataSource: TimerControllerDataSource,
      delegate: TimerControllerDelegate? = nil
   ) {
      // Phase 1.
      self.category = category
      self.dataSource = dataSource
      self.delegate = delegate

      // Phase 2.
      super.init(nibName: nil, bundle: nil)
      
      // Phase 3.
      view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
      setTimePickerDuration()
      if dataSource.categoryIsRunning(category) { setUpdateTimer() }
      
      setupButtons()
      setupLayoutConstraints()
   }

   /// Sets up all buttons' images, sized and action methods.
   private func setupButtons() {
      let imageLoader = ImageLoader(useDefaultSizes: false)
      let defaultSize = ImageLoader.Button.defaultSize
      let categoryIsRunning = dataSource.categoryIsRunning(category)
      
      // Collects each buttons information in a tuple.
      let buttonInfo: [(UIButton, ImageLoader.Button, CGSize, Selector, Bool)] = [
         (playButton,   .play,   2 * defaultSize, #selector(didPressPlay),   categoryIsRunning ),
         (pauseButton,  .pause,  2 * defaultSize, #selector(didPressPause),  !categoryIsRunning),
         (stopButton,   .stop,   defaultSize,     #selector(didPressStop),   false             ),
         (switchButton, .switch, defaultSize,     #selector(didPressSwitch), false             )
      ]
      
      // Sets up each button using the tuples defined before.
      for (button, type, size, action, isHidden) in buttonInfo {
         let image = imageLoader[button: type].resizedKeepingAspect(forSize: size)
         
         button.setImage(image, for: .normal)
         button.addTarget(self, action: action, for: .touchUpInside)
         button.isHidden = isHidden
      }
   }

   /// Sets the update timer to a timer calling `setTimePickerDuration` every second.
   private func setUpdateTimer() {
      updateTimer = Timer.scheduledTimer(
         timeInterval: 1, target: self,
         selector: #selector(setTimePickerDuration),
         userInfo: nil, repeats: true
      )
   }
   
   /// Sets the duration of the time picker to the current track duration of the controller's
   /// category.
   @objc private func setTimePickerDuration() {
      let duration = dataSource.track(for: category).duration
      timePicker.setDuration(to: duration)
   }
   
   /// Updates the controller to be able to handle a given tracking state.
   func updateForTrackingState(running: Bool) {
      updateTimer.invalidate()
      playButton.isHidden = running
      pauseButton.isHidden = !running
      if running { setUpdateTimer() }
   }
   
   // MARK: - Requirements
   
   /// Do not call this initializer! This view does not support storyboards or XIB.
   required init?(coder aDecoder: NSCoder) { fatalError("View doesn't support storyboard or XIB.") }
}

// MARK: - Button Actions

extension TimerController {
   
   /// The action method called, when the play button is pressed.
   @objc private func didPressPlay() {
      updateForTrackingState(running: true)
      delegate?.timerController(self, needsPlayForCategory: category)
   }
   
   /// The action method called, when the pause button is pressed.
   @objc private func didPressPause() {
      updateForTrackingState(running: false)
      delegate?.timerControllerNeedsPause(self)
   }
   
   /// The action method called, when the stop button is pressed.
   @objc private func didPressStop() {
      endDurationEditing()
      delegate?.timerControllerNeedsStop(self)
   }
   
   /// The action method called, when the switch button is pressed.
   @objc private func didPressSwitch() {
      endDurationEditing()
      delegate?.timerControllerNeedsSwitch(self)
   }
}

// MARK: - Timer Editing

extension TimerController {
   
   /// Allows the tracked duration of the current category to be manipulated.
   func beginDurationEditing() {
      // Makes sure the controller is not already in dutation editing mode.
      guard !isEditingDuration else { return }
      
      // Sets up the controller for duration editing.
      playButton.isEnabled = false
      switchButton.isEnabled = false
      if dataSource.categoryIsRunning(category) { didPressPause() }
      
      // Goes into duration editing mode.
      timePicker.beginEditing()
   }
   
   /// Resumes the controller's "normal" state, if it was previously in duration editing mode.
   func endDurationEditing() {
      // Makes sure the controller is in dutation editing mode.
      guard isEditingDuration else { return }
      
      // Unwinds the controller from editing mode.
      playButton.isEnabled = true
      switchButton.isEnabled = true
      timePicker.endEditing()
      
      // Propagates the duration change to the delegate.
      let newDuration = timePicker.selection
      delegate?.timerController(self, updatedDuration: newDuration, forCategory: category)
   }
}

// MARK: - Auto Layout

extension TimerController {
   
   /// Activates the auto layout constraints needed to setup the relationships between all views
   /// involved in creating the timer controller's UI.
   private func setupLayoutConstraints() {
      let buttonStackView = makeButtonStackView()
      let enclosingStackView = UIStackView(arrangedSubviews: [timePicker, buttonStackView])
      enclosingStackView.axis = .vertical
      enclosingStackView.distribution = .fillEqually
      enclosingStackView.alignment = .fill
      
      AutoLayoutHelper(rootView: view, viewToConstrain: enclosingStackView).constrainView()
   }
   
   /// Creates a stack view laying out the buttons used in a timer controller.
   private func makeButtonStackView() -> UIStackView {
      let stackView = UIStackView(
         arrangedSubviews: [stopButton, playButton, pauseButton, switchButton]
      )
      stackView.axis = .horizontal
      stackView.alignment = .center
      stackView.distribution = .fillProportionally
      
      return stackView
   }
}

// MARK: - Timer Controller Data Source

/// A type providing data needed for timer controller to function properly.
protocol TimerControllerDataSource {
   
   func track(for category: Category) -> Track
   
   func categoryIsRunning(_ category: Category) -> Bool
}

// MARK: - Timer Controller Delegate

/// A delegate providing functionality external to a timer controller.
protocol TimerControllerDelegate {
   
   func timerController(_ timerController: TimerController, switchedToCategory category: Category)
   
   func timerController(
      _ timerController: TimerController,
      updatedDuration duration: TimeInterval,
      forCategory category: Category
   )
   
   func timerController(_ timerController: TimerController, needsPlayForCategory category: Category)
   
   func timerControllerNeedsPause(_ timerController: TimerController)
   
   func timerControllerNeedsStop(_ timerController: TimerController)
   
   func timerControllerNeedsSwitch(_ timerController: TimerController)
}
