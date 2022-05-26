//
//  AsyncImage.swift
//  Rck&Mrty
//
//  Created by Aleksandr Paniukov on 02.05.2022.
//

import SwiftUI
import Combine

protocol ImageCache {
    subscript(_ url: URL) -> UIImage? { get set }
}

struct TemporaryImageCache: ImageCache {
    private let cache = NSCache<NSURL, UIImage>()

    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set {
          newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL)
        }
    }
}


class ImageLoader: ObservableObject {
  @Published var image: UIImage?
  private let url: URL

  private var cancellable: AnyCancellable?
  private var cache: ImageCache?

  init(url: URL, cache: ImageCache? = nil) {
    self.url = url
    self.cache = cache
  }

  deinit {
    cancel()
  }

  func cancel() {
    cancellable?.cancel()
  }

  func load() {
    guard image == nil else { return }
    if let image = cache?[url] {
      self.image = image
      return
    }
    cancellable = URLSession.shared.dataTaskPublisher(for: url)
      .map { UIImage(data: $0.data) }
      .replaceError(with: nil)
      .handleEvents(receiveOutput: { [weak self] in self?.cache($0)})
      .receive(on: DispatchQueue.main)
      .sink{ [weak self] in self?.image = $0 }
  }

  private func cache(_ image: UIImage?) {
    image.map { cache?[url] = $0 }
  }
}

struct AsyncImage<PlaceholderView: View>: View {
  @StateObject private var imageLoader: ImageLoader
  private let placeholder: PlaceholderView

  init(
    url: URL,
    cache: ImageCache? = nil,
    @ViewBuilder placeholder: @escaping () -> PlaceholderView
  ) {
    self._imageLoader = StateObject(wrappedValue: ImageLoader(url: url, cache: cache))
    self.placeholder = placeholder()
  }

  var body: some View {
    content
      .onAppear(perform: imageLoader.load)
      .onDisappear(perform: imageLoader.cancel)
  }

  private var content: some View {
    Group {
      if let image = imageLoader.image {
        Image(uiImage: image)
          .resizable()
      } else {
        placeholder
      }
    }
  }
}
