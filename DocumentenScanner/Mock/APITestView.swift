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
    @State var counter: Int = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button(action: {
                self.store.send(.service(action: .createTemplate(name: "Bla", description: "sdfjhskdjh fjk")))
                self.counter = 1
            }) {
                Text("Create Template")
            }
            Button(action: {
                self.store.send(.service(action:
                    .createPage(templateId: self.store.states.serviceState.templateId ?? 0,
                                number: self.counter,
                                imagePath: "asd"))
                )
                self.counter += 1
            }) {
                Text("Create Page")
            }
            Button(action: {
                self.store.send(.service(action:
                    .createAttribute(name: "Attribute 1",
                                     x: 10,
                                     y: 20,
                                     width: 30,
                                     height: 40,
                                     dataType: "Text",
                                     pageId: self.store.states.serviceState.pageId ?? 0)
                    )
                )
            }) {
                Text("Create Attribute")
            }
        }
    }
}

struct APITestView_Previews: PreviewProvider {
    static var previews: some View {
        APITestView().environmentObject(AppStoreMock.getAppStore())
    }
}
