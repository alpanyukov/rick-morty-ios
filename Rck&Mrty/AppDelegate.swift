//
//  AppDelegate.swift
//  Rck&Mrty
//
//  Created by Aleksandr Paniukov on 29.04.2022.
//

import UIKit
import SwiftUI
import ComposableArchitecture

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let window = UIWindow(frame: UIScreen.main.bounds)
    let store = Store(
      initialState: AppState(),
      reducer: appReducer,
      environment: AppEnvironment(apiClient: .live, mainQueue: .main)
    )
    window.rootViewController = UIHostingController(rootView: AppView(store: store))
    window.makeKeyAndVisible()
    self.window = window
    return true
  }


}

