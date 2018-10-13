//
//  TimePicker.swift
//  Track
//
//  Created by Marcus Rossel on 28.09.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Time Picker

final class TimePicker: UIView {
   
   private let pickerView = UIPickerView()
   
   private let coverStack = UIStackView()
   
   private var componentValueMap: EnumMap<TimePickerComponent, Int> {
      return EnumMap<TimePickerComponent, Int> { component in
         return pickerView.selectedRow(inComponent: component.rawValue)
      }
   }
   
   var selection: TimeInterval {
      return TimeInterval(
         hours: componentValueMap[.hour],
         minutes: componentValueMap[.minute],
         seconds: componentValueMap[.second]
      )
   }
   
   var isEditing: Bool {
      return coverStack.isHidden
   }
   
   init() {
      // Phase 2.
      super.init(frame: .zero)
      
      // Phase 3.
      pickerView.dataSource = self
      pickerView.delegate = self
      pickerView.isUserInteractionEnabled = false
      
      setupCoverStack()
      setupLayoutConstraints()
   }
   
   convenience init?(duration: TimeInterval) {
      self.init()
      guard setDuration(to: duration) else { return nil }
   }
   
   private func setupCoverStack() {
      for view in [UIView(), UIView()] {
         view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
         coverStack.addArrangedSubview(view)
      }
      
      coverStack.axis = .vertical
      coverStack.distribution = .equalSpacing
      coverStack.alignment = .fill
   }
   
   // MARK: - Requirements
   
   /// Do not call this initializer! This view does not support storyboards or XIB.
   required init?(coder aDecoder: NSCoder) { fatalError("View doesn't support storyboard or XIB.") }
}

// MARK: - Editing

extension TimePicker {
   
   @discardableResult
   func setDuration(to duration: TimeInterval) -> Bool {
      guard duration >= 0 && duration <= Track.maximumDuration else { return false }
      
      let (hours, minutes, seconds, _) = duration.decomposed
      for (component, value) in [hours, minutes, seconds].enumerated() {
         pickerView.selectRow(value, inComponent: component, animated: true)
      }
      
      return true
   }
   
   func beginEditing() {
      pickerView.isUserInteractionEnabled = true
      coverStack.isHidden = true
      pickerView.reloadAllComponents()
   }
   
   func endEditing() {
      pickerView.isUserInteractionEnabled = false
      coverStack.isHidden = false
      pickerView.reloadAllComponents()
   }
}

// MARK: - Picker View Data Source and Delegate

extension TimePicker: UIPickerViewDataSource, UIPickerViewDelegate {
   
   private enum TimePickerComponent: Int, CaseIterable {
      case hour
      case minute
      case second
      
      var valueCount: Int {
         let dateComponent: Calendar.Component
         
         switch self {
         case .hour: dateComponent = .hour
         case .minute: dateComponent = .minute
         case .second: dateComponent = .second
         }
         
         let maximumRange = Track.calendar.maximumRange(of: dateComponent)!
         let (start, end) = (maximumRange.startIndex, maximumRange.endIndex)
         return maximumRange.distance(from: start, to: end)
      }
   }
   
   func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return TimePickerComponent.allCases.count
   }
   
   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      guard let timePickerComponent = TimePickerComponent(rawValue: component) else {
         fatalError("Received unexpected time picker component.")
      }
      
      return timePickerComponent.valueCount
   }
   
   func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      let now = Date()
      let todaysPassed = now.decomposed(accordingTo: Track.calendar)
      let selectedTime = componentValueMap
      
      let selectionIsLexicographicallyGreater: Bool =
            selectedTime[.hour] > todaysPassed.hours
         ||
            selectedTime[.hour] == todaysPassed.hours &&
            selectedTime[.minute] > todaysPassed.minutes
         ||
            selectedTime[.hour] == todaysPassed.hours &&
            selectedTime[.minute] == todaysPassed.minutes &&
            selectedTime[.second] > todaysPassed.seconds
      
      if selectionIsLexicographicallyGreater {
         setDuration(to: TimeInterval.passedOfDay(atDate: now, accordingTo: Track.calendar))
      }
   }

   func pickerView(
      _ pickerView: UIPickerView,
      viewForRow row: Int,
      forComponent component: Int,
      reusing view: UIView?
   ) -> UIView {
      
      let rowLabel: UILabel
      let fontSize: CGFloat = isEditing ? 50 : 85
      
      if let reusedLabel = view as? UILabel {
         rowLabel = reusedLabel
      } else {
         rowLabel = UILabel()
         rowLabel.font = UIFont(name: "HelveticaNeue-Thin", size: fontSize)
         rowLabel.textAlignment = .center
      }
      
      rowLabel.text = String(format: "%02d", row)
      
      return rowLabel
   }
   
   func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
      return isEditing ? 50 : 85
   }
}

// MARK: - Auto Layout

extension TimePicker {
   
   private func setupLayoutConstraints() {
      AutoLayoutHelper(rootView: self, viewToConstrain: pickerView).constrainView()
      AutoLayoutHelper(rootView: pickerView, viewToConstrain: coverStack).constrainView()
      
      for view in coverStack.arrangedSubviews {
         view.setContentCompressionResistancePriority(.required, for: .vertical)
         view.setContentHuggingPriority(.required, for: .vertical)
         
         view.heightAnchor.constraint(equalTo: pickerView.heightAnchor, multiplier: 0.32)
            .isActive = true
      }
   }
}

// MARK: - Time Picker Delegate

protocol TimePickerDelegate {
   
   func timePicker(_ timePicker: TimePicker, didSelectDuration duration: TimeInterval)
}

extension TimePickerDelegate {
   
   func timePicker(_ timePicker: TimePicker, didSelectDuration duration: TimeInterval) { }
}
