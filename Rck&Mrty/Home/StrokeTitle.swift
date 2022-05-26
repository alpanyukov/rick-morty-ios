//
//  StrokeTitle.swift
//  Rck&Mrty
//
//  Created by Aleksandr Paniukov on 26.05.2022.
//

import UIKit
import SwiftUI

struct StrokeTitle: UIViewRepresentable {
  typealias UIViewType = UILabel
  let text: String
  let color: UIColor
  let font: UIFont
  let strokeWidth: Float

  func makeUIView(context: Context) -> UIViewType {
    let strokeLabel = UILabel(frame: .zero)
    strokeLabel.attributedText = NSAttributedString(
      string: text,
      attributes:[
          .strokeWidth: strokeWidth,
          .strokeColor: color,
          .foregroundColor: UIColor.clear,
          .font: font,
          .kern: 3
      ]
    )
    strokeLabel.backgroundColor = .clear
    strokeLabel.numberOfLines = 0
    strokeLabel.lineBreakMode = .byWordWrapping
    strokeLabel.translatesAutoresizingMaskIntoConstraints = false
    strokeLabel.setContentHuggingPriority(.required, for: .horizontal)
    strokeLabel.setContentHuggingPriority(.required, for: .vertical)
    return strokeLabel
  }
  func updateUIView(_ uiView: UIViewType, context: Context) {
    //
  }
}
