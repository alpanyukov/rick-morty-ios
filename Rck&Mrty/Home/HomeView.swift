//
//  HomeView.swift
//  Rck&Mrty
//
//  Created by Aleksandr Paniukov on 29.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct HomeView: View {
  let theme = Theme.dynamic
  let store: Store<ListState, ListActions>
  private let cache = TemporaryImageCache()

  private let layout = [
    GridItem(.adaptive(minimum: 100), spacing: 0)
  ]

  var body: some View {
    NavigationView {
      ScrollView {
        // MARK: - title
        VStack(alignment: .leading, spacing: 24) {
          StrokeTitle(
            text: "Rick\nand\nMorty".uppercased(),
            color: theme.colors.main.uiColor,
            font: .systemFont(ofSize: 72, weight: .black),
            strokeWidth: 1
          )
          Text("character\nbook".uppercased())
            .font(.system(size: 32, weight: .black, design: .default))
            .foregroundColor(theme.colors.main.color)
        }
          .padding([.horizontal], 16)
          .frame(
            maxWidth: .infinity,
            alignment: .topLeading
          )
        // MARK: - grid
        WithViewStore(self.store) { viewStore in
          LazyVGrid(columns: layout, spacing: 0) {
            ForEach(viewStore.items) { item in
              row(for: item, viewStore: viewStore)
            }
          }
          .onAppear {
            viewStore.send(.load)
          }
          if viewStore.state.loadingState == .loading {
            HStack {
              Spacer()
              ProgressView()
              Spacer()
            }.padding()
          }
        }
      }
      .navigationBarHidden(true)
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }

  @ViewBuilder
  func row(for item: DetailInfo, viewStore: ViewStore<ListState,ListActions>) -> some View {
    NavigationLink(
      destination: IfLetStore(
        self.store.scope(state: \.detailsState, action: ListActions.details),
        then: DetailsView.init
      ),
      tag: item.id,
      selection: viewStore.binding(
        get: \.detailsState?.id,
        send: ListActions.setNavigation(selection:)
      )
    ) {
      AsyncImage(url: item.image, cache: self.cache) {
        ProgressView()
      }
        .aspectRatio(contentMode: .fit)
        .onAppear {
          if item == viewStore.items.last {
            viewStore.send(.load)
          }
        }
    }
  }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
          store: Store(
            initialState: ListState(),
            reducer: listReducer,
            environment: ListEnvironment(
              apiClient: .dev,
              mainQueue: .main
            )
          )
        )
    }
}
