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
                let template = AppStoreMock.realTemplate()
                self.store.send(.newTemplate(action: .setTemplate(template: template)))
                self.store.send(.service(action: .createTemplate))
            }) {
                Text("Upload Template")
            }
            Button(action: {
                self.store.send(.service(action: .getTemplateList))
            }) {
                Text("Get Templates")
            }
            Button(action: {
                self.store.send(.auth(action:
                    .login(email: "mii@mii.mii", password: "mii2mii!")))
            }) {
                Text("Login")
            }
        }
    }
}

struct APITestView_Previews: PreviewProvider {
    static var previews: some View {
        APITestView().environmentObject(AppStoreMock.getAppStore())
    }
}
