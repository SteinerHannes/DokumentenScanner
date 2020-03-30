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
    @State private var isLoggedin: Bool = false

    init() {
        print("init ContentView")
    }

    var body: some View {
        if isLoggedin {
            return VStack(alignment: .leading, spacing: 0) {
                Group {
                    if self.store.states.routes.isPageSelectViewPresented {
                        PageSelectView()
                    } else {
                        TemplatesView()
                    }
                }
                .environmentObject(self.store)
                .navigationViewStyle(StackNavigationViewStyle())
            }.onAppear {
                self.store.send(.login)
            }.eraseToAnyView()
        } else {
            return WelcomeView()
                .eraseToAnyView()
        }
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
