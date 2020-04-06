//
//  ContentView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 24.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AppStore

    @State private var selectedView: Int = 0

    init() {
        print("init ContentView")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if self.store.states.authState.isLoggedin {
                if self.store.states.routes.isPageSelectViewPresented {
                    PageSelectView()
                } else {
                    TemplatesView()
                }
            } else {
                WelcomeView()
            }
        }
        .environmentObject(self.store)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(
                AppStore(initialState: .init(),
                         reducer: appReducer,
                         environment: AppEnviorment()
                )
            )
    }
}
