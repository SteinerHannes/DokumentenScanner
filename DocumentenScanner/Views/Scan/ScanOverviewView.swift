//
//  ScanOverviewView.swift
//  DokumentenScanner
//
//  Created by Hannes Steiner on 18.07.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

struct ScanOverviewView: View {
    @EnvironmentObject var store: AppStore
    @State var template: Template?

    var body: some View {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 16) {
                    if self.store.states.currentTemplate == nil {
                        HStack(alignment: .center, spacing: 0) {
                            Spacer()
                            Text("Keine Vorlagen ausgewählt.")
                            Spacer()
                        }
                        .sectionBackground()
                    } else {
                        TemplateCard(template: self.store.states.currentTemplate!, showChevron: false)
                        .sectionBackground()
                    }
                }
            }.navigationBarTitle(Text("Scan"))
            .navigationBarItems(trailing: trailingItem())
    }

    func trailingItem() -> some View {
        NavigationLink(destination: TemplateSelectView()) {
            Text("Vorlage auswählen")
        }.isDetailLink(false)
    }
}

struct TemplateSelectView: View {
    @EnvironmentObject var store: AppStore
    @State var selection: String?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 16) {
                if self.store.states.teamplates.isEmpty {
                    HStack(alignment: .center, spacing: 0) {
                        Spacer()
                        Text("Keine Vorlagen vorhanden.")
                        Spacer()
                    }
                    .sectionBackground()
                } else {
                    ForEach(self.store.states.teamplates, id: \.id) { template in
                        NavigationLink(
                            destination:
                            LazyView(TemplateDetailView(template: template)
                                .environmentObject(self.store)),
                            tag: template.id,
                            selection: self.$selection) {
                                Button(action: {
                                    self.store.send(.setCurrentTemplate(id: template.id))
                                    self.selection = template.id
                                    self.store.send(.ocr(action: .clearResult))
                                }) {
                                    TemplateCard(template: template)
                                }
                        }
                        .sectionBackground()
                    }
                }
            }
        }
        .navigationBarTitle("Vorlagen", displayMode: .large)
    }
}

struct ScanOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScanOverviewView()
                .environmentObject(AppStoreMock.getAppStore())
        }
    }
}
