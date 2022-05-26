//
//  AppState.swift
//  Rck&Mrty
//
//  Created by Aleksandr Paniukov on 03.05.2022.
//

import ComposableArchitecture

struct AppState: Equatable {
  var listState = ListState()
  var favoriteState: FavoritesState {
    get {
      FavoritesState(items: listState.favoriteList)
    }
    set {
      listState.favoriteList = newValue.items
    }
  }
}

enum AppActions: Equatable {
  case list(ListActions)
}

struct AppEnvironment {
  var apiClient: APIClient
  var mainQueue: AnySchedulerOf<DispatchQueue>
}

let appReducer = Reducer<AppState, AppActions, AppEnvironment>.combine(
  listReducer.pullback(
    state: \AppState.listState,
    action: /AppActions.list,
    environment: { ListEnvironment(apiClient: $0.apiClient, mainQueue: $0.mainQueue) }
  ),
  Reducer { state, action, _ in
    switch action {
    case .list:
      return .none
    }
  }
)

struct FavoritesState: Equatable {
  var items: Set<DetailInfo>
}
