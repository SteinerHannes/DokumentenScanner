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
                self.uplaodTemplate()
            }) {
                Text("Upload Template")
            }
        }
    }

    func uplaodTemplate() {
        let template = AppStoreMock.realTemplate()
        self.store.send(.newTemplate(action: .setTemplate(template: template)))
        self.store.send(.service(action: .createTemplate))

    }
}

struct APITestView_Previews: PreviewProvider {
    static var previews: some View {
        APITestView().environmentObject(AppStoreMock.getAppStore())
    }
}
