//
//  ViewController.swift
//  Rck&Mrty
//
//  Created by Aleksandr Paniukov on 29.04.2022.
//

import SwiftUI
import Combine
import ComposableArchitecture

enum AppScreen: String {
  case home
  case favorites
  case search
}

struct AppView: View {
  private let store: Store<AppState, AppActions>
  // TODO: use appState for tabSelecting
  @State private var isSearchPresenting = false
  @State private var currentTab = AppScreen.home
  @State private var previousTab = AppScreen.home

  init(store: Store<AppState, AppActions>) {
    self.store = store
    UITabBar.appearance().isTranslucent = false
    UITabBar.appearance().backgroundColor = Theme.dynamic.colors.bg.uiColor
    UITabBar.appearance().barTintColor = Theme.dynamic.colors.bg.uiColor
    UIScrollView.appearance().bounces = false
  }

  var body: some View {
    TabView(selection: $currentTab) {
      HomeView(
        store: store.scope(state: \.listState, action: AppActions.list)
      )
        .tabItem {
          let iconName = currentTab == .home ? "house.fill" : "house"
          Image(iconName, bundle: .main)
            .renderingMode(.template)
        }
        .tag(AppScreen.home)
        .applyBG()
      FavoritesView()
        .tabItem {
          let iconName = currentTab == .favorites ? "heart.fill" : "heart"
          Image(iconName, bundle: .main)
            .renderingMode(.template)
        }
        .tag(AppScreen.favorites)
        .applyBG()
      Text("")
        .tabItem {
          Image("magnifyingglass", bundle: .main)
            .renderingMode(.template)
        }
        .tag(AppScreen.search)
        .applyBG()
    }
    .accentColor(Theme.dynamic.colors.main.color)
    .onReceive(Just(currentTab)) {
      if currentTab == .search {
        isSearchPresenting = true
        currentTab = previousTab
      } else {
        previousTab = $0
      }
    }
    .sheet(isPresented: $isSearchPresenting) {
      SearchView()
        .applyBG()
    }
  }
}

extension View {
  func applyBG() -> some View {
    frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Theme.dynamic.colors.bg.color.edgesIgnoringSafeArea(.all))
  }
}

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(
      store: Store(
        initialState: AppState(),
        reducer: appReducer,
        environment: AppEnvironment(apiClient: .dev, mainQueue: .main)
      )
    ).preferredColorScheme(.dark)
  }
}

