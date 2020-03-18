//
//  LinkedRegionsView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 17.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

//swiftlint:disable multiple_closures_with_trailing_closure
struct LinkedRegionsView: View {
    @EnvironmentObject var store: AppStore

    @State var isActive: Bool = false

    var body: some View {
        List {
            Section {
                Button(action: {
                    self.isActive = true
                }) {
                    Text("Neuen Link hinzufügen")
                }
            }
            if self.store.states.newTemplateState.newTemplate?.links.isEmpty ?? true {
                Section {
                    HStack(alignment: .center, spacing: 0) {
                        Spacer()
                        Text("Keine Links vorhanden.")
                        Spacer()
                    }
                }
            } else {
                Section {
                    Text("asd")
                }
            }
        }
        .sheet(isPresented: self.$isActive) {
            AddLinkView().environmentObject(self.store)
        }
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("Linkliste", displayMode: .inline)
        .navigationBarItems(trailing: trailingItem())
    }

    func trailingItem() -> some View {
        Button(action: {
            self.store.send(.addNewTemplate(template: self.store.states.newTemplateState.newTemplate!))
            self.store.send(.routing(action: .showContentView))
            self.store.send(.newTemplate(action: .clearState))
            self.store.send(.routing(action: .showContentView))
        }) {
            Text("Speichern")
        }
    }
}

struct LinkedRegionsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LinkedRegionsView()
                .environmentObject(AppStoreMock.getAppStore())
        }
    }
}
