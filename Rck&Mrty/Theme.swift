//
//  Theme.swift
//  Rck&Mrty
//
//  Created by Aleksandr Paniukov on 02.05.2022.
//

import SwiftUI

struct Theme: Equatable {
  let colors: Colors
}

struct Colors: Equatable {
  let main: CompositeColor
  let secondary: CompositeColor
  let greyBG: CompositeColor
  let bg: CompositeColor

  struct CompositeColor: Equatable {
    let uiColor: UIColor
    var color: Color {
      Color(uiColor)
    }

    init(_ uiColor: UIColor) {
      self.uiColor = uiColor
    }

    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
      self.uiColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
  }
}

extension Theme {
  static let dynamic = Theme(
    colors: Colors(
      main: Colors.CompositeColor(UIColor{ traits in
        traits.userInterfaceStyle == .dark ? Theme.dark.colors.main.uiColor : Theme.light.colors.main.uiColor
      }),
      secondary: Colors.CompositeColor(UIColor{ traits in
        traits.userInterfaceStyle == .dark ? Theme.dark.colors.secondary.uiColor : Theme.light.colors.secondary.uiColor
      }),
      greyBG: Colors.CompositeColor(UIColor{ traits in
        traits.userInterfaceStyle == .dark ? Theme.dark.colors.greyBG.uiColor : Theme.light.colors.greyBG.uiColor
      }),
      bg: Colors.CompositeColor(UIColor{ traits in
        traits.userInterfaceStyle == .dark ? Theme.dark.colors.bg.uiColor : Theme.light.colors.bg.uiColor
      })
    )
  )

  static let light = Theme(
    colors: Colors(
      main: Colors.CompositeColor(red: 0.24, green: 0.24, blue: 0.25, alpha: 1),
      secondary: Colors.CompositeColor(red: 0.77, green: 0.78, blue: 0.78, alpha: 1.00),
      greyBG: Colors.CompositeColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.00),
      bg: Colors.CompositeColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00)
    )
  )

  static let dark = Theme(
    colors: Colors(
      main: Colors.CompositeColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00),
      secondary: Colors.CompositeColor(red: 0.38, green: 0.38, blue: 0.38, alpha: 1.00),
      greyBG: Colors.CompositeColor(red: 0.29, green: 0.30, blue: 0.31, alpha: 1.00),
      bg: Colors.CompositeColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1.00)
    )
  )
}
