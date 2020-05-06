//
//  RemoteImage.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 08.04.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import class Kingfisher.KingfisherManager

extension Image {
    func fetchingRemoteImage(from url: String) -> some View {
        ModifiedContent(content: self, modifier: RemoteImageModifier(url: url))
    }
}

struct RemoteImageModifier: ViewModifier {

    let url: String
    @State private var fetchedImage: UIImage?

    func body(content: Content) -> some View {
        if let image = fetchedImage {
            return Image(uiImage: image)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .eraseToAnyView()
        } else {
            return content
                .frame(idealWidth: 110, maxWidth: UIScreen.main.bounds.width-32,
                       idealHeight: 200,
                       maxHeight: UIScreen.main.bounds.width)
                .background(
                    Rectangle()
                        .foregroundColor(.gray)
                        .opacity(0.1)
                        .cornerRadius(4)
                )
                .shadow(radius: 3)
                .onAppear(perform: fetch)
                .eraseToAnyView()
        }
    }

    private func fetch() {
        KingfisherManager.shared.retrieveImage(with: URL(string: baseAuthority + url)!) { result in
            self.fetchedImage = try? result.get().image
        }
    }
}
