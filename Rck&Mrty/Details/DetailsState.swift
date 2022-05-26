//
//  DetailsStore.swift
//  Rck&Mrty
//
//  Created by Aleksandr Paniukov on 03.05.2022.
//

import ComposableArchitecture
import Foundation

struct DetailInfo: Equatable, Hashable, Identifiable {
  var id: Int
  var name: String
  var status: String
  var species: String
  var gender: String
  var image: URL

  // https://rickandmortyapi.com/api/character/2
  static var mock: DetailInfo {
    DetailInfo(
      id: 2,
      name: "Morty Smith",
      status: "Alive",
      species: "Human",
      gender: "Male",
      image: URL(string: "https://rickandmortyapi.com/api/character/avatar/2.jpeg")!
    )
  }
}

extension DetailInfo: Decodable {
  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case status
    case species
    case gender
    case image
  }
}


struct DetailsState: Equatable {
  var id: Int
  var data: DetailInfo?
  var isFavorite: Bool

  init(id: Int, isFavorite: Bool = false) {
    self.id = id
    self.isFavorite = false
  }
}

enum DetailsAction: Equatable {
  case detailsAppeared
  case detailsResponse(Result<DetailInfo, APIClient.Failure>)
  case favoriteTapped
}

struct DetailsEnvironment {
  var apiClient: APIClient
  var mainQueue: AnySchedulerOf<DispatchQueue>
}

let detailsReducer = Reducer<DetailsState, DetailsAction, DetailsEnvironment> {
  state, action, environment in
  switch action {
  case .detailsAppeared:
    struct DetailsInfoId: Hashable {}
    return environment.apiClient.detailsInfo(state.id)
      .receive(on: environment.mainQueue)
      .catchToEffect(DetailsAction.detailsResponse)
      .cancellable(id: DetailsInfoId(), cancelInFlight: true)
  case let .detailsResponse(.success(info)):
    state.data = info
    return .none
  case .detailsResponse(.failure):
    state.data = nil
    return .none
  case .favoriteTapped:
    state.isFavorite.toggle()
    return .none
  }
}


struct APIClient {
  let detailsInfo: (Int) -> Effect<DetailInfo, Failure>
  let listPaginated: (_ page: Int) -> Effect<[DetailInfo], Failure>

  struct Failure: Error, Equatable {}
}

extension APIClient {
  private struct ListResponse: Decodable {
    let results: [DetailInfo]
  }
  static let live = APIClient(
    detailsInfo: { id in
      let url = URL(string: "https://rickandmortyapi.com/api/character/\(id)")!
      return URLSession.shared.dataTaskPublisher(for: url)
        .map {data, _ in data}
        .decode(type: DetailInfo.self, decoder: JSONDecoder())
        .mapError{_ in Failure()}
        .eraseToEffect()
    },
    listPaginated: { pageNumber in
      let url = URL(string: "https://rickandmortyapi.com/api/character/?page=\(pageNumber)")!
      return URLSession.shared.dataTaskPublisher(for: url)
        .map {data, _ in data}
        .decode(type: ListResponse.self, decoder: JSONDecoder())
        .map(\.results)
        .mapError{_ in Failure()}
        .eraseToEffect()
    }
  )

  static let dev = APIClient(
    detailsInfo: { _ in Effect(value: DetailInfo.mock) },
    listPaginated: {_ in Effect(value: [DetailInfo.mock])}
  )
}
