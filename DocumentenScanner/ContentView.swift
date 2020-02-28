//
//  ContentView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 24.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedView: Int = 0
    
    var body: some View {
        ZStack {
            TabView(selection: self.$selectedView) {
                TemplatesView().tabItem {
                    Text("Templates")
                }.tag(0)
                OCRView().tabItem {
                    Text("OCRScanner")
                }.tag(1)
            }
            
            if self.appState.isCreateTemplateViewPresented {
                NavigationView {
                    LazyView(CreateTemplateView())
                }
            } else if self.appState.isNewTemplateViewPresented {
                NavigationView {
                    LazyView(NewTemplateView())
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppState())
    }
}
