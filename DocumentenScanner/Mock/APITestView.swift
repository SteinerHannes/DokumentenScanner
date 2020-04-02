//
//  APITestView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 02.04.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
//swiftlint:disable multiple_closures_with_trailing_closure
struct APITestView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button(action: {
                self.store.send(.service(action: .createTemplate(name: "Bla", description: "sdfjhskdjh fjk")))
            }) {
                Text("Create Template")
            }
        }
    }
}

struct APITestView_Previews: PreviewProvider {
    static var previews: some View {
        APITestView().environmentObject(AppStoreMock.getAppStore())
    }
}
