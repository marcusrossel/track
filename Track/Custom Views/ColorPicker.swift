//
//  ColorPicker.swift
//  Track
//
//  Created by Marcus Rossel on 16.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

/// A view used for choosing a color.
final class ColorPicker: UIView {

   /// The sliders for changing the values of the color components.
   private var sliders: EnumMap<UIColor.Component, UISlider>
   
   /// The view showing the currently selected color.
   private let selectionPanel: UIView
   
   /// The color currently selected within the color picker.
   var selection: UIColor {
      // Updates the selection panel and sliders when the selection changes.
      didSet {
         selectionPanel.backgroundColor = selection
         
         let changedComponents = differingComponents(between: selection, and: oldValue)
         setSliderTints(for: changedComponents)
      }
   }
   
   /// Creates a color picker in the state of having selected a given color.
   init(selection: UIColor) {
      // Phase 1.
      self.selection = selection
      selectionPanel = UIView()
      sliders = EnumMap { _ in UISlider() }
      
      // Phase 2.
      super.init(frame: .zero)
      
      // Phase 3.
      setupSelectionPanel()
      setupSliders()
      setSliderTints()
      setupLayoutConstraints()
   }
   
   /// Sets up fixed properties for the sliders.
   private func setupSliders() {
      for (_, slider) in sliders.dictionary {
         slider.setShadow(radius: 3, opacity: 0.25, offset: CGSize(width: 0, height: 1))
         slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
      }
   }
   
   /// A convenience method for setting up the selection panel's style properties.
   private func setupSelectionPanel() {
      selectionPanel.backgroundColor = selection
      selectionPanel.layer.cornerRadius = 15
      selectionPanel.setShadow()
   }
   
   /// A convenience method for setting the slider tints of given components according to the
   /// current `selection`.
   private func setSliderTints(
      for components: Set<UIColor.Component> = Set(UIColor.Component.allCases)
   ) {
      for (component, tint) in makeSliderTints(for: selection, components: components) {
         sliders[component].value = Float(selection.decomposed[component])
         sliders[component].minimumTrackTintColor = tint.track
         sliders[component].thumbTintColor = tint.thumb
      }
   }
   
   /// A convenience method for retrieving the color component associated with a given slider.
   private func colorComponent(for target: UISlider) -> UIColor.Component {
      for (component, slider) in sliders.dictionary {
         if slider === target { return component }
      }
      fatalError("Expected never to reach this point.")
   }
   
   /// A convenience method for determining which color components differ between given colors.
   private func differingComponents(between color1: UIColor, and color2: UIColor)
   -> Set<UIColor.Component> {
      let differingComponents: [UIColor.Component] = color1.decomposed.dictionary.compactMap {
         pair in
         let (component, value) = pair
         return (value != color2.decomposed[component]) ? component : nil
      }
      
      return Set(differingComponents)
   }
   
   // MARK: - Requirements
   
   /// Do not call this initializer! This view does not support storyboards or XIB.
   required init?(coder aDecoder: NSCoder) { fatalError("View doesn't support storyboard or XIB.") }
}

// MARK: - Styling

extension ColorPicker {
   
   /// Calculates the colors of slider tracks and thumbs for a given color and components.
   private func makeSliderTints(
      for color: UIColor,
      components tragetComponents: Set<UIColor.Component> = Set(UIColor.Component.allCases)
   ) -> [UIColor.Component: (track: UIColor, thumb: UIColor)] {
      
      // Sets up helper function for calculating the tints' color values.
      let trackMaximum: CGFloat = 0.8
      let trackDesaturation: (CGFloat) -> CGFloat = { 0.75 - ($0 * 0.3) }
      
      let thumbMaximum: (CGFloat) -> CGFloat = { 0.7 + ($0 * 0.3) }
      let thumbDesaturation: (CGFloat) -> CGFloat = { 0.5 + ($0 * 0.5) }
      
      let colorComponentValues = color.decomposed
      var tints: [UIColor.Component: (track: UIColor, thumb: UIColor)] = [:]
      
      // Calculates and sets the tint colors for each target component.
      for targetComponent in tragetComponents {
         // Gets the value for the current target component.
         let targetComponentValue = colorComponentValues[targetComponent]
         
         var trackComponentValues: [UIColor.Component: CGFloat] = [:]
         var thumbComponentValues: [UIColor.Component: CGFloat] = [:]
         
         // Fills the above dictionaries with the desaturation values.
         for tintComponent in [UIColor.Component.red, .green, .blue] {
            trackComponentValues[tintComponent] = trackDesaturation(targetComponentValue)
            thumbComponentValues[tintComponent] = thumbDesaturation(targetComponentValue)
         }
         
         // Sets the tints' color values to the maximum values for the target component.
         trackComponentValues[targetComponent] = trackMaximum
         thumbComponentValues[targetComponent] = thumbMaximum(targetComponentValue)
         
         // Makes sure the alpha is always set to 1.
         trackComponentValues[.alpha] = 1
         thumbComponentValues[.alpha] = 1
         
         // Creates the tint colors.
         let trackColor = UIColor(components: trackComponentValues)
         let thumbColor = UIColor(components: thumbComponentValues)
         
         tints[targetComponent] = (track: trackColor, thumb: thumbColor)
      }
      
      return tints
   }
}

// MARK: - Public API

extension ColorPicker {
   
   /// Shows the slider for a given color component. If it was not hidden before, nothing changes.
   func show(_ component: UIColor.Component) {
      sliders[component].isHidden = false
   }
   
   /// Hides the slider for a given color component. If it was not showing before, nothing changes.
   func hide(_ component: UIColor.Component) {
      sliders[component].isHidden = true
   }
}

// MARK: - User Interaction

extension ColorPicker {
   
   /// Handels the change of a slider value.
   @objc private func sliderValueChanged(_ slider: UISlider) {
      let sliderValue = CGFloat(slider.value)
      let affectedComponent = colorComponent(for: slider)
      
      var colorComponents = selection.decomposed
      colorComponents[affectedComponent] = sliderValue
      
      selection = UIColor(components: colorComponents.dictionary)
   }
}

// MARK: - Auto Layout

extension ColorPicker {
   
   private func setupLayoutConstraints() {
      let sliderStackView = makeSliderStackView()
      
      AutoLayoutHelper(rootView: self).setupViewsForAutoLayout([sliderStackView, selectionPanel])
      
      let guide = safeAreaLayoutGuide
      
      selectionPanel.topAnchor.constraint(
         equalTo: guide.topAnchor, constant: .defaultSpacing
      ).isActive = true
      
      selectionPanel.leadingAnchor.constraint(
         equalTo: guide.leadingAnchor, constant: .defaultSpacing
      ).isActive  = true
      
      selectionPanel.trailingAnchor.constraint(
         equalTo: guide.trailingAnchor, constant: -.defaultSpacing
      ).isActive = true

      sliderStackView.bottomAnchor.constraint(
         equalTo: guide.bottomAnchor, constant: -.defaultSpacing
      ).isActive = true
      
      sliderStackView.leadingAnchor.constraint(
         equalTo: guide.leadingAnchor, constant: .defaultSpacing
      ).isActive = true
      
      sliderStackView.trailingAnchor.constraint(
         equalTo: guide.trailingAnchor, constant: -.defaultSpacing
      ).isActive = true
      
      sliderStackView.topAnchor.constraint(
         equalTo: selectionPanel.bottomAnchor, constant: .defaultSpacing
      ).isActive = true
      
      selectionPanel.heightAnchor.constraint(
         equalTo: sliderStackView.heightAnchor, multiplier: 0.4
      ).isActive = true
   }
   
   /// Creates a stack view laying out the sliders appropriately.
   private func makeSliderStackView() -> UIStackView {
      let sortedSliders = sliders.dictionary
         .sorted { $0.key.rawValue < $1.key.rawValue }
         .map { $0.value }
      
      let sliderStackView = UIStackView(arrangedSubviews: sortedSliders)
      sliderStackView.axis = .vertical
      sliderStackView.alignment = .fill
      sliderStackView.distribution = .fillEqually
      sliderStackView.spacing = .defaultSpacing / 2
      
      return sliderStackView
   }
}
