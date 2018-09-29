//
//  TimerController.swift
//  Track
//
//  Created by Marcus Rossel on 20.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

#warning("Idea")
// Add more fades and animations
//
// change the look of the time picker labels
//
// add !minor! "Hour(s)"/"h", "Minute(s)"/"min" and "Second(s)"/"s" labels 

// MARK: - Timer Controller

/// A view controller that displays the current track state for a given category.
/// Additionally the controller provides means of changing the a category's track state, as well as
/// an interface for switching to another category.
final class TimerController: UIViewController {

   /// A type providing data needed to display a sensible view.
   private var dataSource: TimerControllerDataSource
   
   /// A coordinator that provides external (delegate) functionality.
   private var delegate: TimerControllerDelegate?

   /// The category whose track is currently being managed by the controller.
   var category: Category {
      didSet {
         setTimerDuration()
         categoryIsRunning = dataSource.categoryIsRunning(category)
         delegate?.timerController(self, isTrackingCategory: category)
      }
   }
   
   #warning("Barely pulling its weight. Should maybe be a function performing the didSet.")
   /// An indicator for whether the category's current track is running or not.
   /// This information is used to avoid redundant update requests for the category's track.
   private var categoryIsRunning: Bool {
      didSet {
         updateTimer.invalidate()
         playButton.isHidden = categoryIsRunning
         pauseButton.isHidden = !categoryIsRunning
         
         if categoryIsRunning {
            setTimerDuration()
            updateTimer = makeUpdateTimer()
         }
      }
   }
   
   private(set) var isEditingDuration = false {
      didSet { playButton.isEnabled = !isEditingDuration }
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

   init(
      category: Category,
      dataSource: TimerControllerDataSource,
      delegate: TimerControllerDelegate? = nil
   ) {
      // Phase 1.
      self.category = category
      self.dataSource = dataSource
      self.delegate = delegate
      categoryIsRunning = dataSource.categoryIsRunning(category)

      // Phase 2.
      super.init(nibName: nil, bundle: nil)
      
      // Phase 3.
      view.backgroundColor = .white
      setTimerDuration()
      if categoryIsRunning { updateTimer = makeUpdateTimer() }
      
      setupButtons()
      setupLayoutConstraints()
      
      delegate?.timerController(self, isTrackingCategory: category)
   }

   /// Sets up all buttons' image and action method.
   private func setupButtons() {
      let imageLoader = ImageLoader(useDefaultSizes: false)
      let defaultSize = ImageLoader.Button.defaultSize
      
      // Collects each buttons information in a tuple.
      let buttonInfo = [
         (playButton,   ImageLoader.Button.play, 2 * defaultSize, #selector(didPressPlay)  ),
         (pauseButton,  .pause,                  2 * defaultSize, #selector(didPressPause) ),
         (stopButton,   .stop,                   defaultSize,     #selector(didPressStop)  ),
         (switchButton, .switch,                 defaultSize,     #selector(didPressSwitch))
      ]
      
      // Sets up each button using the tuples defined before.
      for item in buttonInfo {
         let image = imageLoader[button: item.1].resizedKeepingAspect(forSize: item.2)
         item.0.setImage(image, for: .normal)
         item.0.addTarget(self, action: item.3, for: .touchUpInside)
      }
      
      // Sets the correct play/pause state.
      playButton.isHidden = categoryIsRunning
      pauseButton.isHidden = !categoryIsRunning
   }

   /// Creates a timer calling `setTimerDuration` every second.
   private func makeUpdateTimer() -> Timer {
      return Timer.scheduledTimer(
         timeInterval: 1,
         target: self,
         selector: #selector(setTimerDuration),
         userInfo: nil,
         repeats: true
      )
   }
   
   @objc private func setTimerDuration() {
      let duration = dataSource.track(for: category).duration
      timePicker.setDuration(to: duration)
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      delegate?.setupNavigationBar(for: self)
   }
   
   // MARK: - Requirements
   
   /// Do not call this initializer! This view does not support storyboards or XIB.
   required init?(coder aDecoder: NSCoder) { fatalError("View doesn't support storyboard or XIB.") }
}

// MARK: - Button Actions

extension TimerController {
   
   /// The action method called, when the play button is pressed.
   @objc private func didPressPlay() {
      // Sanity check.
      guard !categoryIsRunning else { fatalError() }
      categoryIsRunning = true
      
      delegate?.timerController(self, needsPlayForCategory: category)
   }
   
   /// The action method called, when the pause button is pressed.
   @objc private func didPressPause() {
      // Sanity check.
      guard categoryIsRunning else { fatalError() }
      categoryIsRunning = false
      
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
   
   func beginDurationEditing() {
      guard !isEditingDuration else { return }
      isEditingDuration = true
      
      if categoryIsRunning { didPressPause() }
      timePicker.beginEditing()
   }
   
   #warning("Transfer track state from before if possible.")
   func endDurationEditing() {
      guard isEditingDuration else { return }
      isEditingDuration = false
      
      timePicker.endEditing()
      let newDuration = timePicker.selection
      
      delegate?.timerController(self, needsUpdatedDuration: newDuration)
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
   
   /// Creates a stack view lying out the buttons used in a timer controller.
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
   
   func timerController(_ timerController: TimerController, isTrackingCategory category: Category)
   
   func timerController(
      _ timerController: TimerController, needsUpdatedDuration duration: TimeInterval
   )
   
   func timerController(_ timerController: TimerController, needsPlayForCategory category: Category)
   
   func timerControllerNeedsPause(_ timerController: TimerController)
   
   func timerControllerNeedsStop(_ timerController: TimerController)
   
   func timerControllerNeedsSwitch(_ timerController: TimerController)
   
   func setupNavigationBar(for controller: TimerController)
}

/// Default implementations making the delegate methods optional.
extension TimerControllerDelegate {
   
//   func timerController(
//      _ timerController: TimerController, isTrackingCategory category: Category
//   ) { }
//
//   func timerController(
//      _ timerController: TimerController, needsUpdatedDuration duration: TimeInterval
//   ) { }
//
//   func timerController(
//      _ timerController: TimerController, needsPlayForCategory category: Category
//   ) { }
//
//   func timerControllerNeedsPause(_ timerController: TimerController) { }
//
//   func timerControllerNeedsStop(_ timerController: TimerController) { }
//
//   func timerControllerNeedsSwitch(_ timerController: TimerController) { }
//
//   func setupNavigationBar(for controller: TimerController) { }
}
