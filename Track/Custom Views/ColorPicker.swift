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
   private var sliders: [UIColor.Component: UISlider] = [:]
   
   /// The view showing the currently selected color.
   private let selectionPanel = UIView()
   
   /// The color currently selected within the color picker.
   var selection: UIColor {
      // Updates the selection panel and sliders when the selection changes.
      didSet {
         selectionPanel.backgroundColor = selection
         
         let changedComponents = differingComponents(between: selection, and: oldValue)
         for pair in makeSliderTrackColors(for: selection, components: changedComponents) {
            let (component, trackColor) = pair
            sliders[component]?.value = Float(selection.decomposed[component]!)
            sliders[component]?.minimumTrackTintColor = trackColor
         }
      }
   }
   
   /// Creates a color picker in the state of having selected a given color.
   init(selection: UIColor) {
      // Phase 1.
      self.selection = selection
      
      // Phase 2.
      super.init(frame: .zero)
      
      // Phase 3.
      setupSliders(with: selection)
      setupDisplayPanel(with: selection)
      setupLayoutConstraints()
   }
   
   /// A convenience method for setting up the sliders' style and functional properties.
   private func setupSliders(with color: UIColor) {
      // For each component - gets the track color, creates a slider, sets the sliders position and
      // hooks it up to a action method for value change.
      for trackComponent in makeSliderTrackColors(for: color) {
         let (component, trackColor) = trackComponent
         let colorValue = color.decomposed[component]!
         let slider = UISlider()
         
         slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
         slider.value = Float(colorValue)
         slider.minimumTrackTintColor = trackColor
         
         sliders[component] = slider
      }
   }
   
   /// A convenience method for setting up the display panel's style properties.
   private func setupDisplayPanel(with color: UIColor) {
      selectionPanel.backgroundColor = color
      selectionPanel.layer.cornerRadius = 15
      selectionPanel.setDefaultShadow()
   }
   
   /// A convenience method for retrieving the color component associated with a given slider.
   private func colorComponent(for target: UISlider) -> UIColor.Component {
      for (component, slider) in sliders {
         if slider === target { return component }
      }
      fatalError("Expected never to reach this point.")
   }
   
   /// A convenience method for determining which color components differ between given colors.
   private func differingComponents(between color1: UIColor, and color2: UIColor)
   -> Set<UIColor.Component> {
      let differingComponents: [UIColor.Component] = color1.decomposed.compactMap { pair in
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
   
   /// Calculates the colors of slider tracks for a given color and components.
   private func makeSliderTrackColors(
      for color: UIColor,
      components: Set<UIColor.Component> = Set(UIColor.Component.allCases)
   ) -> [UIColor.Component: UIColor] {
      
      // The function used to determine how intense the base color values should be for the
      // component's track.
      let transparency: (CGFloat) -> CGFloat = { colorValue in
         // Causes the intensity to be between 0.1 and 0.4
         return 0.9 - (colorValue * 0.3)
      }
      
      let componentValues = color.decomposed
      var trackComponents: [UIColor.Component: UIColor] = [:]
      
      for component in components {
         let componentValue = componentValues[component]!
         
         var trackColorComponents: [UIColor.Component: CGFloat] = [
            .red:   transparency(componentValue),
            .green: transparency(componentValue),
            .blue:  transparency(componentValue),
         ]
         
         trackColorComponents[component] = 0.8
         trackColorComponents[.alpha] = 1
         
         trackComponents[component] = UIColor(components: trackColorComponents)
      }
      
      return trackComponents
   }
}

// MARK: - Public API

extension ColorPicker {
   
   /// Shows the slider for a given color component. If it was not hidden before, nothing changes.
   func show(_ component: UIColor.Component) {
      sliders[component]?.isHidden = false
   }
   
   /// Hides the slider for a given color component. If it was not showing before, nothing changes.
   func hide(_ component: UIColor.Component) {
      sliders[component]?.isHidden = true
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
      
      selection = UIColor(components: colorComponents)
   }
}

// MARK: - Auto Layout

extension ColorPicker {
   
   private func setupLayoutConstraints() {
      let sliderStackView = makeSliderStackView()
      
      AutoLayoutHelper(rootView: self).setupViewsForAutoLayout([sliderStackView, selectionPanel])
      
      let guide = safeAreaLayoutGuide
      
      let panelTop = selectionPanel.topAnchor.constraint(
         equalTo: guide.topAnchor, constant: .defaultSpacing
      )
      let panelLeading = selectionPanel.leadingAnchor.constraint(
         equalTo: guide.leadingAnchor, constant: .defaultSpacing
      )
      let panelTrailing = selectionPanel.trailingAnchor.constraint(
         equalTo: guide.trailingAnchor, constant: -.defaultSpacing
      )

      let slidersBottom = sliderStackView.bottomAnchor.constraint(
         equalTo: guide.bottomAnchor, constant: -.defaultSpacing
      )
      let slidersLeading = sliderStackView.leadingAnchor.constraint(
         equalTo: guide.leadingAnchor, constant: .defaultSpacing
      )
      let slidersTrailing = sliderStackView.trailingAnchor.constraint(
         equalTo: guide.trailingAnchor, constant: -.defaultSpacing
      )
      
      let gap = sliderStackView.topAnchor.constraint(
         equalTo: selectionPanel.bottomAnchor, constant: .defaultSpacing
      )
      let sizeRatio = selectionPanel.heightAnchor.constraint(
         equalTo: sliderStackView.heightAnchor, multiplier: 0.4
      )
      
      NSLayoutConstraint.activate([
         panelTop, panelLeading, panelTrailing,
         slidersBottom, slidersLeading, slidersTrailing,
         gap, sizeRatio
      ])
   }
   
   /// Creates a stack view laying out the sliders appropriately.
   private func makeSliderStackView() -> UIStackView {
      let sortedSliders = sliders
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
