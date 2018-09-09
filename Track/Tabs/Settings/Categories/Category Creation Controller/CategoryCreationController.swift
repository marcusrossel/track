//
//  CreateCategoryController.swift
//  Track
//
//  Created by Marcus Rossel on 18.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

#warning("Incomplete.")

import UIKit

// MARK: - Category Creation Controller Delegate

protocol CategoryCreationControllerDelegate {
   
   func categoryCreationControllerCanSaveCategory(
      _ categoryCreationController: CategoryCreationController
   )
   
   func categoryCreationControllerCanNotSaveCategory(
      _ categoryCreationController: CategoryCreationController
   )
   
   func categoryCreationControllerDidRequestSave(
      _ categoryCreationController: CategoryCreationController,
      forCategory category: Category
   )
   
   func setupNavigationBar(for controller: CategoryCreationController)
}

extension CategoryCreationControllerDelegate {
   
   func setupNavigationBar(for controller: CategoryCreationController) { }
}

// MARK: - Category Creation Controller

final class CategoryCreationController: UIViewController {

   private var coordinator: CategoryCreationControllerDelegate?
   private let categoryManager: Category.Manager
   
   let titleTextField: UITextField
   let colorPicker: ColorPicker
   
   private(set) var category: Category?
   
   init(categoryManager: Category.Manager, delegate: CategoryCreationControllerDelegate? = nil) {
      // Phase 1.
      coordinator = delegate
      self.categoryManager = categoryManager
      titleTextField = UITextField()
      colorPicker = ColorPicker(selection: .gray)
      colorPicker.hide(.alpha)
      
      // Phase 2.
      super.init(nibName: nil, bundle: nil)
      
      // Phase 3.
      view.backgroundColor = .white
      
      titleTextField.placeholder = "Category Title"
      titleTextField.delegate = self
      
      setupLayoutConstraints()
   }
   
   private func setupLayoutConstraints() {
      let stackView = UIStackView(arrangedSubviews: [titleTextField, colorPicker])
      stackView.axis = .vertical
      stackView.alignment = .fill
      stackView.distribution = .fillProportionally
      
      AutoLayoutHelper(rootView: view , viewToConstrain: stackView)
         .constrainView(generalInset: .defaultSpacing)
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      coordinator?.setupNavigationBar(for: self)
   }
   
   // MARK: - Requirements
   
   required init?(coder aDecoder: NSCoder) { fatalError("App does not use storyboard or XIB.") }
}

// MARK: - Public API

extension CategoryCreationController {
   
   func saveCategoryIfPossible() {
      guard let category = category else { return }
      coordinator?.categoryCreationControllerDidRequestSave(self, forCategory: category)
   }
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
      
      if categoryManager.uniqueCategory(with: trimmedText) != nil || trimmedText.isEmpty {
         category = nil
         coordinator?.categoryCreationControllerCanNotSaveCategory(self)
      } else {
         category = Category(title: trimmedText, color: colorPicker.selection)
         coordinator?.categoryCreationControllerCanSaveCategory(self)
      }
      
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

