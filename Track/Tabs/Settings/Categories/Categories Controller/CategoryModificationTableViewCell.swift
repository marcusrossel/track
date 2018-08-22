//
//  CategoryModificationTableViewCell.swift
//  Track
//
//  Created by Marcus Rossel on 19.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Category Modification Table View Cell Data Source

protocol CategoryModificationTableViewCellDataSource: AnyObject {
   
   func numberOfActionsForTableViewCell(_ cell: CategoryModificationTableViewCell) -> Int
   
   func tableViewCell(
      _ categoryModificationTableViewCell: CategoryModificationTableViewCell,
      needsSetupForCell cell: CategoryModificationActionCell,
      atRow row: Int
   )
}

// MARK: - Category Modification Table View Cell

final class CategoryModificationTableViewCell: UITableViewCell {
   
   static let identifier = "CategoryModificationTableViewCell"

   let collectionView: UICollectionView
   weak var datasource: CategoryModificationTableViewCellDataSource?
   
   override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      // Phase 1.
      let flowLayout = UICollectionViewFlowLayout()
      flowLayout.minimumInteritemSpacing = 0
      collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
      
      // Phase 2.
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      
      // Phase 3.
      collectionView.dataSource = self
      collectionView.delegate = self
      collectionView.register(
         CategoryModificationActionCell.self,
         forCellWithReuseIdentifier: CategoryModificationActionCell.identifier
      )
      
      collectionView.isScrollEnabled = false
      collectionView.delaysContentTouches = false
      
      collectionView.contentInset = UIEdgeInsets(
         top: 0, left: .defaultSpacing, bottom: 0, right: .defaultSpacing
      )
      collectionView.backgroundColor = backgroundColor
      backgroundColor = .clear
      
      setupLayoutConstraints()
   }
   
   // MARK: - Requirements
   
   required init?(coder aDecoder: NSCoder) { fatalError("App does not use storyboard or XIB.") }
}

// MARK: - Collection View Data Source

extension CategoryModificationTableViewCell: UICollectionViewDataSource {
   
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int)
   -> Int {
      return datasource?.numberOfActionsForTableViewCell(self) ?? 0
   }
   
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      guard
         let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoryModificationActionCell.identifier, for: indexPath
         ) as? CategoryModificationActionCell
      else { fatalError("Dequeued unexpected collection view cell.") }
      
      cell.contentView.layer.cornerRadius = 15
      cell.contentView.layer.borderColor = UIColor.tableViewBorder.cgColor
      cell.contentView.layer.borderWidth = .tableViewBorder
      cell.contentView.backgroundColor = .white
      datasource?.tableViewCell(self, needsSetupForCell: cell, atRow: indexPath.row)

      return cell
   }
}

// MARK: - Collection View Delegate Flow Layout

extension CategoryModificationTableViewCell: UICollectionViewDelegateFlowLayout {
   
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      let numberOfActions = datasource?.numberOfActionsForTableViewCell(self) ?? 1
      
      let spacing = CGFloat.defaultSpacing + (.defaultSpacing / CGFloat(numberOfActions))
      let width = bounds.width / CGFloat(numberOfActions) - spacing
      
      return CGSize(width: width, height: bounds.height)
   }
   
   func collectionView(
      _ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath
   ) {
      let cell = collectionView.cellForItem(at: indexPath)
      cell?.contentView.backgroundColor = .lightGray
   }
   
   func collectionView(
      _ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath
   ) {
      let cell = collectionView.cellForItem(at: indexPath)
      cell?.contentView.backgroundColor = .white
   }
}

// MARK: - Auto Layout

extension CategoryModificationTableViewCell {
   
   private func setupLayoutConstraints() {
      setupViewsForAutoLayout([collectionView])
      
      let guide = contentView.safeAreaLayoutGuide
      
      let top = collectionView.topAnchor.constraint(equalTo: guide.topAnchor)
      let bottom = collectionView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
      let leading = collectionView.leadingAnchor.constraint(equalTo: guide.leadingAnchor)
      let trailing = collectionView.trailingAnchor.constraint(equalTo: guide.trailingAnchor)
      
      NSLayoutConstraint.activate([top, bottom, leading, trailing])
   }
   
   private func setupViewsForAutoLayout(_ views: [UIView]) {
      for view in views {
         view.translatesAutoresizingMaskIntoConstraints = false
         contentView.addSubview(view)
      }
   }
}

// MARK: - Category Modification Action Cell

final class CategoryModificationActionCell: UICollectionViewCell {
   
   static let identifier = "CategoryModificationActionCell"
   
   let textLabel: UILabel
   let imageView: UIImageView
   
   override init(frame: CGRect) {
      // Phase 1.
      textLabel = UILabel()
      imageView = UIImageView(image: UIImage())
      
      // Phase 2.
      super.init(frame: frame)
      
      // Phase 3.
      textLabel.text = ""
      imageView.contentMode = .scaleAspectFit
      
      setupLayoutConstraints()
   }
   
   var image: UIImage {
      get {
         guard let image = imageView.image else {
            fatalError("Expected to always find an image.")
         }
         return image
      }
      set { imageView.image = newValue }
   }
   
   var text: String {
      get {
         guard let text = textLabel.text else {
            fatalError("Expected to always find text.")
         }
         return text
      }
      set { textLabel.text = newValue }
   }
   
   // MARK: - Requirements
   
   required init?(coder aDecoder: NSCoder) { fatalError("App does not use storyboard or XIB.") }
}

// MARK: - Category Modification Action Cell Auto Layout

extension CategoryModificationActionCell {
   
   private func setupLayoutConstraints() {
      let stackView = UIStackView(arrangedSubviews: [imageView, textLabel])
      stackView.axis = .horizontal
      stackView.alignment = .center
      stackView.distribution = .fill
      stackView.spacing = .defaultSpacing
      stackView.isUserInteractionEnabled = false
      
      imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
      
      setupViewsForAutoLayout([stackView])
      
      let guide = contentView.safeAreaLayoutGuide
      
      let stackTop = stackView.topAnchor.constraint(
         equalTo: guide.topAnchor, constant: .defaultSpacing
      )
      let stackBottom = stackView.bottomAnchor.constraint(
         equalTo: guide.bottomAnchor, constant: -.defaultSpacing
      )
      let stackLeading = stackView.leadingAnchor.constraint(
         equalTo: guide.leadingAnchor, constant: .defaultSpacing
      )
      let stackTrailing = stackView.trailingAnchor.constraint(
         equalTo: guide.trailingAnchor, constant: -.defaultSpacing
      )

      NSLayoutConstraint.activate([stackTop, stackLeading, stackTrailing, stackBottom])
   }
   
   private func setupViewsForAutoLayout(_ views: [UIView]) {
      for view in views {
         view.translatesAutoresizingMaskIntoConstraints = false
         contentView.addSubview(view)
      }
   }
}
