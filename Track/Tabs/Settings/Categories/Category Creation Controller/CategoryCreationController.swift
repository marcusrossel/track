//
//  CreateCategoryController.swift
//  Track
//
//  Created by Marcus Rossel on 18.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Category Creation Controller Delegate

protocol CategoryCreationControllerDelegate {
   
   func setupNavigationBar(for controller: CategoryCreationController)
   
   func categoryCreationControllerCanSaveCategory(
      _ categoryCreationController: CategoryCreationController
   )
   
   func categoryCreationControllerCanNotSaveCategory(
      _ categoryCreationController: CategoryCreationController
   )
}

extension CategoryCreationControllerDelegate {
   
   func setupNavigationBar(for controller: CategoryCreationController) { }
}

// MARK: - Category Creation Controller

final class CategoryCreationController: UIViewController {

   private let coordinator: CategoryCreationControllerDelegate
   private let categoryManager: Category.Manager
   
   let titleTextField: UITextField
   let colorPicker: ColorPicker
   
   private(set) var category: Category?
   
   init(categoryManager: Category.Manager, delegate: CategoryCreationControllerDelegate) {
      // Phase 1.
      coordinator = delegate
      self.categoryManager = categoryManager
      titleTextField = UITextField()
      colorPicker = ColorPicker(selection: .gray)
      
      // Phase 2.
      super.init(nibName: nil, bundle: nil)
      
      // Phase 3.
      titleTextField.placeholder = "Category Title"
      titleTextField.delegate = self
      
      setupLayoutConstraints()
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      coordinator.setupNavigationBar(for: self)
   }
   
   // MARK: - Requirements
   
   required init?(coder aDecoder: NSCoder) { fatalError("App does not use storyboard or XIB.") }
}

// MARK: - Text Field Delegate

extension CategoryCreationController: UITextFieldDelegate {
   
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
         coordinator.categoryCreationControllerCanNotSaveCategory(self)
      } else {
         category = Category(title: trimmedText, color: colorPicker.selection)
         coordinator.categoryCreationControllerCanSaveCategory(self)
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

// MARK: - Auto Layout

extension CategoryCreationController {
   
   private func setupLayoutConstraints() {
      let stackView = UIStackView()
      stackView.axis = .vertical
      stackView.alignment = .fill
      stackView.distribution = .fillProportionally
      
      setupViewsForAutoLayout([stackView])
      
      let guide = view.safeAreaLayoutGuide
      
      let top = stackView.topAnchor.constraint(
         equalTo: guide.topAnchor, constant: .defaultSpacing
      )
      let bottom = stackView.bottomAnchor.constraint(
         equalTo: guide.bottomAnchor, constant: -.defaultSpacing
      )
      let leading = stackView.leadingAnchor.constraint(
         equalTo: guide.leadingAnchor, constant: .defaultSpacing
      )
      let trailing = stackView.trailingAnchor.constraint(
         equalTo: guide.trailingAnchor, constant: -.defaultSpacing
      )
      
      NSLayoutConstraint.activate([top, bottom, leading, trailing])
   }
   
   private func setupViewsForAutoLayout(_ views: [UIView]) {
      for view in views {
         view.translatesAutoresizingMaskIntoConstraints = false
         self.view.addSubview(view)
      }
   }
}

