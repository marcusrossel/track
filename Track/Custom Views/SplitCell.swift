//
//  SplitCell.swift
//  Track
//
//  Created by Marcus Rossel on 19.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Split Cell Data Source

protocol SplitCellDataSource: AnyObject {
   
   func numberOfSubcellsForSplitCell(_ cell: SplitCell) -> Int
   
   func splitCell(
      _ cell: SplitCell,
      needsSetupForSubcell subcell: UICollectionViewCell,
      atPosition position: Int
   )
}

// MARK: - Split Table View Cell

/// A table view cell in which one can layout a row of independant subcells.
/// Any table view using this type should disable seperators, to get an acceptable UI.
final class SplitCell: UITableViewCell {
   
   /// An identifier associated with the table view cell.
   /// This can be used when registering and dequeueing a split cell.
   static let identifier = "SplitCell"
   
   /// The identifer used to identify the subcells layed out by the split cell.
   private let subcellIdentifier = "SplitCell.Subcell"

   /// The collection view that holds the split cell's subcells.
   private let collectionView: UICollectionView
   
   /// The split cell's data source.
   weak var datasource: SplitCellDataSource?
   
   /// The type of subcell layed out by the split cell.
   var subcellType: AnyClass = UICollectionViewCell.self {
      didSet {
         collectionView.register(subcellType, forCellWithReuseIdentifier: subcellIdentifier)
      }
   }
   
   override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      // Phase 1.
      let flowLayout = UICollectionViewFlowLayout()
      collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
      
      // Phase 2.
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      
      // Phase 3.
      backgroundColor = .clear
      setupCollectionView(with: flowLayout)
      
      // Sets up the cell's auto layout constraints.
      AutoLayoutHelper(rootView: contentView, viewToConstrain: collectionView).constrainView(
         including: [
            .top(inset: 0), .bottom(inset: 0),
            .leading(inset: .defaultSpacing), .trailing(inset: .defaultSpacing)
         ]
      )
   }
   
   /// A convenience method for setting up the collection view and its flow layout.
   private func setupCollectionView(with flowLayout: UICollectionViewFlowLayout) {
      // Needed to allow for truely custom spacing of the split subcells.
      flowLayout.minimumInteritemSpacing = 0
      
      // Sets up basic functional properties.
      collectionView.dataSource = self
      collectionView.delegate = self
      collectionView.register(subcellType, forCellWithReuseIdentifier: subcellIdentifier)
      
      // Makes sure the collection view is only a means of presentation, not interaction.
      collectionView.isScrollEnabled = false
      collectionView.backgroundColor = .clear
   }
   
   // MARK: - Requirements
   
   /// Do not call this initializer! This view does not support storyboards or XIB.
   required init?(coder aDecoder: NSCoder) { fatalError("View doesn't support storyboard or XIB.") }
}

// MARK: - Collection View Data Source

extension SplitCell: UICollectionViewDataSource {
   
   /// Specifies the number of subcells in a split cell.
   /// The value is specified by the data source, or `0` if no data source is set.
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int)
   -> Int {
      return datasource?.numberOfSubcellsForSplitCell(self) ?? 0
   }
   
   /// Sets up a subcell. The setup can be customized by the data source.
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
   -> UICollectionViewCell {
      
      // Dequeues the subcell.
      let cell = collectionView.dequeueReusableCell(
         withReuseIdentifier: subcellIdentifier, for: indexPath
      )
      
      // Sets up the subcell.
      styleSubcell(cell)
      datasource?.splitCell(self, needsSetupForSubcell: cell, atPosition: indexPath.row)

      return cell
   }
   
   /// A convenience method for giving a subcell its default style.
   private func styleSubcell(_ cell: UICollectionViewCell) {
      cell.contentView.layer.cornerRadius = 15
      cell.contentView.layer.borderColor = UIColor.tableViewBorder.cgColor
      cell.contentView.layer.borderWidth = .tableViewBorder
      cell.contentView.backgroundColor = .white
   }
}

// MARK: - Collection View Delegate Flow Layout

extension SplitCell: UICollectionViewDelegateFlowLayout {
   
   /// Sets the size of each subcell as to fit the number of them specified by the data source
   /// within the split cell.
   func collectionView(
      _ collectionView: UICollectionView,
      layout collectionViewLayout: UICollectionViewLayout,
      sizeForItemAt indexPath: IndexPath
   ) -> CGSize {
      
      // Gets the number of subcells contained in the split cell.
      // The minimum is specified as `1`, to avoid divide-by-zero errors in the following code.
      let numberOfSubcells = min(1, datasource?.numberOfSubcellsForSplitCell(self) ?? 0)
      
      // Calculates the size components of the subcells, giving them an even spacing.
      let spacing = .defaultSpacing + (.defaultSpacing / CGFloat(numberOfSubcells))
      let width = bounds.width / CGFloat(numberOfSubcells) - spacing
      
      return CGSize(width: width, height: bounds.height)
   }
}
