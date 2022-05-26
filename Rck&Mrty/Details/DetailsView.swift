//
//  DetailsView.swift
//  Rck&Mrty
//
//  Created by Aleksandr Paniukov on 30.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct DetailsView: View {
  private let imageCache = TemporaryImageCache()
  private let theme = Theme.dynamic
  let store: Store<DetailsState, DetailsAction>

  var body: some View {
    WithViewStore(self.store) { viewStore in
        ScrollView(.vertical, showsIndicators: false) {
          VStack {
            HStack {
              Group {
                if let image = viewStore.state.data?.image {
                  AsyncImage(url: image, cache: imageCache) {
                    ProgressView()
                  }
                  .aspectRatio(contentMode: .fit)
                } else {
                  Color.clear
                }
              }
              .frame(width: 300, height: 300, alignment: .topLeading)
              .cornerRadius(15)
              .overlay(
                RoundedRectangle(cornerRadius: 15)
                  .stroke(theme.colors.main.color, lineWidth: 1)
              )
            }
              .frame(maxWidth: .infinity, alignment: .center)
              .padding([.top], 20)

            VStack {
              HStack {
                Text(viewStore.state.data?.name ?? "")
                  .foregroundColor(theme.colors.main.color)
                  .font(.system(size: 34, weight: .bold, design: .default))
                Spacer()
                Button(action: {
                  withAnimation {
                    viewStore.send(.favoriteTapped)
                  }
                }) {
                  Image(viewStore.state.isFavorite ? "heart.fill" : "heart", bundle: .main)
                    .renderingMode(.template)
                    .foregroundColor(viewStore.state.isFavorite ? theme.colors.bg.color : theme.colors.main.color)
                }
                .frame(width: 48, height: 48, alignment: .center)
                .background(
                  viewStore.state.isFavorite ? theme.colors.main.color : theme.colors.greyBG.color
                )
                .clipShape(Circle())
              }
              if let viewState = viewStore.state.data {
                VStack(alignment: .leading, spacing: 16) {
                  DataRow(label: "Status", value: viewState.status) {
                    Divider()
                      .background(theme.colors.main.color)
                  }
                  DataRow(label: "Species", value: viewState.species) {
                    Divider()
                      .background(theme.colors.main.color)
                  }
                  DataRow(label: "Gender", value: viewState.gender)
                }
                .padding([.top], 20)
                .frame(maxWidth: .infinity, alignment: .leading)
              }
            }
            .padding([.horizontal], 16)
            .padding([.top], 35)
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
          viewStore.send(.detailsAppeared)
        }
        .applyBG()
    }
  }
}

struct DataRow<Content>: View where Content: View {
  let label: String
  let value: String
  @ViewBuilder let divider: () -> Content

  private let theme = Theme.dynamic

  var body: some View {
    let lineHeight = 28.0
    let size = 22.0
    let diff = lineHeight - size
    VStack(alignment: .leading) {
      Text("\(label):")
        .font(.system(size: size, weight: .bold, design: .default))
        .foregroundColor(theme.colors.secondary.color)
        .lineSpacing(diff)
        .padding(.vertical, diff / 2)
      Text(value)
        .font(.system(size: size, weight: .bold, design: .default))
        .foregroundColor(theme.colors.main.color)
        .lineSpacing(diff)
        .padding(.vertical, diff / 2)
      divider()
    }
  }
}

extension DataRow where Content == EmptyView {
  init(label: String, value: String) {
    self.init(label: label, value: value) {
      EmptyView()
    }
  }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
      DetailsView(
        store: Store(
          initialState: DetailsState(id: 2),
          reducer: detailsReducer,
          environment: DetailsEnvironment(
            apiClient: .dev,
            mainQueue: .main
          )
        )
      )
    }
}
