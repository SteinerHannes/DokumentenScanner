//
//  DocumentPreview.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 24.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

struct DocumentPreview: View {
    let template: Template

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(alignment: .center, spacing: 15) {
                ForEach(0 ..< self.template.pages.count) { index in
                    Image(uiImage: self.template.pages[index].image)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .shadow(color: .shadow, radius: 5, x: 0, y: 0)
                        .frame(maxWidth: UIScreen.main.bounds.width-32,
                               maxHeight: UIScreen.main.bounds.width)
                }
            }
            .padding()
        }.frame(height: 200)
    }
}

struct DocumentPreview_Previews: PreviewProvider {
    static var previews: some View {
        DocumentPreview(template: AppStoreMock.getTemplate())
    }
}
