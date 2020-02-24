//
//  ContentView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 24.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedView:Int = 0
    
    var body: some View {
        TabView(selection: self.$selectedView) {
            CreateTemplateView().tabItem {
                Text("bla")
            }.tag(0)
            TemplatesView().tabItem {
                Text("Templates")
            }.tag(1)
            OCRView().tabItem {
                Text("OCRScanner")
            }.tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
