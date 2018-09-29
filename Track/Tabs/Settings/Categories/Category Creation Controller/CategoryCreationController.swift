//
//  CreateCategoryController.swift
//  Track
//
//  Created by Marcus Rossel on 18.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Category Creation Controller

final class CategoryCreationController: UIViewController {

   private var delegate: CategoryCreationControllerDelegate?
   private let categoryManager: CategoryManager
   
   let titleTextField = UITextField()
   let colorPicker: ColorPicker
   let saveButton = UIButton()
   let cancelButton = UIButton()
   
   init(categoryManager: CategoryManager, delegate: CategoryCreationControllerDelegate? = nil) {
      // Phase 1.
      self.delegate = delegate
      self.categoryManager = categoryManager
      
      colorPicker = ColorPicker(selection: .gray)
      colorPicker.hide(.alpha)
      
      // Phase 2.
      super.init(nibName: nil, bundle: nil)
      
      // Phase 3.
      view.backgroundColor = .white
      
      setupTextField()
      setupButtons()
      setupLayoutConstraints()
   }
   
   private func setupTextField() {
      titleTextField.delegate = self
      titleTextField.placeholder = "Category Title"
      titleTextField.borderStyle = .roundedRect
   }
   
   private func setupButtons() {
      let imageLoader = ImageLoader()
      
      saveButton.isEnabled = false
      
      saveButton.setImage(imageLoader[button: .accept], for: .normal)
      cancelButton.setImage(imageLoader[button: .cancel], for: .normal)
      
      saveButton.addTarget(self, action: #selector(didPressSaveButton), for: .touchUpInside)
      cancelButton.addTarget(self, action: #selector(didPressCancelButton), for: .touchUpInside)
   }
   
   private func setupLayoutConstraints() {
      let buttonStackView = UIStackView(arrangedSubviews: [saveButton, cancelButton])
      buttonStackView.axis = .horizontal
      buttonStackView.alignment = .center
      buttonStackView.distribution = .fillEqually
      
      let enclosingStackView = UIStackView(
         arrangedSubviews: [titleTextField, colorPicker, buttonStackView]
      )
      enclosingStackView.axis = .vertical
      enclosingStackView.alignment = .fill
      enclosingStackView.distribution = .fillProportionally
      
      AutoLayoutHelper(rootView: view , viewToConstrain: enclosingStackView)
         .constrainView(generalInset: .defaultSpacing)
      
      colorPicker.heightAnchor.constraint(
         lessThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.35
      ).isActive = true
      
      titleTextField.setContentHuggingPriority(.defaultHigh, for: .vertical)
      buttonStackView.setContentHuggingPriority(.defaultHigh, for: .vertical)
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      delegate?.setupNavigationBar(for: self)
   }
   
   @objc private func didPressSaveButton() {
      #warning("End text field editing properly first.")
      
      guard let categoryTitle = titleTextField.text else {
         fatalError("Expected text field to contain valid category title.")
      }
      
      let category = Category(title: categoryTitle, color: colorPicker.selection)!
      
      delegate?.categoryCreationController(self, didRequestSaveForCategory: category)
   }

   @objc private func didPressCancelButton() {
      delegate?.categoryCreationControllerDidCancel(self)
   }
   
   // MARK: - Requirements
   
   /// Do not call this initializer! This view does not support storyboards or XIB.
   required init?(coder aDecoder: NSCoder) { fatalError("View doesn't support storyboard or XIB.") }
}

// MARK: - Text Field Delegate

extension CategoryCreationController: UITextFieldDelegate {
   
   func textFieldDidChange(_ textField: UITextField) {
      
   }
   
   func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
      textField.returnKeyType = .done
      return true
   }
   
   func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
      guard let trimmedText = textField.text else {
         fatalError("Expected text field to contain text.")
      }
      
      textField.resignFirstResponder()
      
      saveButton.isEnabled =
         !(categoryManager.uniqueCategory(with: trimmedText) != nil) &&
         !trimmedText.isEmpty
      
      return true
   }
   
   func textField(
      _ textField: UITextField,
      shouldChangeCharactersIn range: NSRange,
      replacementString replacement: String
   ) -> Bool {
      let oldText = (textField.text ?? "") as NSString
      let newText = oldText.replacingCharacters(in: range, with: replacement)
      
      return newText.count <= 30
   }
}

// MARK: - Category Creation Controller Delegate

/// A delegate providing functionality external to a category creation controller.
protocol CategoryCreationControllerDelegate {
   
   func categoryCreationControllerDidCancel(
      _ categoryCreationController: CategoryCreationController
   )
   
   func categoryCreationController(
      _ categoryCreationController: CategoryCreationController,
      didRequestSaveForCategory category: Category
   )
   
   func setupNavigationBar(for controller: CategoryCreationController)
}

/// Default implementations making the delegate methods optional.
extension CategoryCreationControllerDelegate {
   
//   func categoryCreationControllerDidCancel(
//      _ categoryCreationController: CategoryCreationController
//   ) { }
//
//   func categoryCreationController(
//      _ categoryCreationController: CategoryCreationController,
//      didRequestSaveForCategory category: Category
//   ) { }
//
//   func setupNavigationBar(for controller: CategoryCreationController) { }
}
