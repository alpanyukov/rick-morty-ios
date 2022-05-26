//
//  ListState.swift
//  Rck&Mrty
//
//  Created by Aleksandr Paniukov on 29.04.2022.
//

import ComposableArchitecture

struct ListState: Equatable {
  enum LoadingState: Equatable {
    case error(String)
    case loading
    case idle(Int)
  }
  var items: [DetailInfo] = []
  var favoriteList: Set<DetailInfo> = []
  var nextPage = 1
  var loadingState: LoadingState = .idle(0)
  var detailsState: DetailsState?
}

enum ListActions: Equatable {
  case load
  case loadResponse(Result<[DetailInfo], APIClient.Failure>)
  case setNavigation(selection: Int?)
  case details(DetailsAction)
}

struct ListEnvironment {
  var apiClient: APIClient
  var mainQueue: AnySchedulerOf<DispatchQueue>
}

let listReducer = Reducer<ListState, ListActions, ListEnvironment>.combine(
  detailsReducer
    .optional()
    .pullback(
      state: \ListState.detailsState,
      action: /ListActions.details,
      environment: { DetailsEnvironment(apiClient: $0.apiClient, mainQueue: $0.mainQueue) }
    ),
  Reducer<ListState, ListActions, ListEnvironment> {
   state, action, environment in
   switch action {
   case .details(.favoriteTapped):
     guard
      let detailsState = state.detailsState,
      let item = state.items.first(where: { $0.id == detailsState.id })
     else { return .none }
     if detailsState.isFavorite {
       state.favoriteList.insert(item)
     } else {
       state.favoriteList.remove(item)
     }
     return .none
   case .load:
     guard state.loadingState != .loading else { return .none }
     state.loadingState = .loading
     struct LoadId: Hashable {}
     return environment.apiClient.listPaginated(state.nextPage)
       .receive(on: environment.mainQueue)
       .catchToEffect(ListActions.loadResponse)
       .cancellable(id: LoadId(), cancelInFlight: true)
   case .loadResponse(.success(let items)):
     state.loadingState = .idle(state.nextPage)
     state.items.append(contentsOf: items)
     state.nextPage += 1
     return .none
   case .loadResponse(.failure):
     state.loadingState = .error("Cant load items")
     return .none
   case .setNavigation(selection: .some(let id)):
     guard let item = state.items.first(where: { $0.id == id }) else { return .none }
     let isFavorite = state.favoriteList.contains(item)
     state.detailsState = DetailsState(id: item.id, isFavorite: isFavorite)
     return .none
   case .setNavigation(selection: .none):
     state.detailsState = nil
     return .none
   case .details:
     return .none
   }
 }
)
