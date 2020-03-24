//
//  DocumentInfo.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 24.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

struct DocumentInfo: View {
    let template: Template

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            //swiftlint:disable line_length
            Text("Das Dokument hat \(self.template.pages.count) \(self.template.pages.count == 1 ? "Seite" : "Steiten")")
                //swiftlint:enable line_length
                .font(.callout)
                .foregroundColor(.label)
            Text(self.template.info)
                .font(.footnote)
                .foregroundColor(.secondaryLabel)
                .lineLimit(3)
        }.padding(.horizontal)
    }
}

struct DocumentInfo_Previews: PreviewProvider {
    static var previews: some View {
        DocumentInfo(template: AppStoreMock.getTemplate())
    }
}
