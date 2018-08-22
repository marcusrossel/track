//
//  Code Dump.swift
//  Track
//
//  Created by Marcus Rossel on 22.08.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

final class _Track: Codable {
   var start: Date
   var end: Date?
   var categoryID: Category.ID
}

final class _TrackManager {
   
   private(set) var tracks: [_Track] = []
   
   var runningTrack: _Track? {
      return tracks.first { $0.end == nil }
   }
   
}

func _textColor(contrasting background: UIColor, whitePreferenceModifier: CGFloat = 10)
-> UIColor {
   let luminosity: (UIColor) -> CGFloat = {
      0.2126 * pow($0.decomposed[.red]!, 2.2) +
      0.7152 * pow($0.decomposed[.green]!, 2.2) +
      0.0722 * pow($0.decomposed[.blue]!, 2.2)
   }
      
   let luminosityDifference: (UIColor, UIColor) -> CGFloat = {
      let luminosities = [$0, $1].map(luminosity).sorted()
      return (luminosities[1] + 0.05) / (luminosities[0] + 0.05)
   }
      
   let deltaBlack = luminosityDifference(background, .black)
   let deltaWhite = luminosityDifference(background, .white) + whitePreferenceModifier
      
   return (deltaBlack > deltaWhite) ? .black : .white
}
