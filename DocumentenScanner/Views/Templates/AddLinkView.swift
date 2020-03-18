//
//  AddLinkView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 17.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

//swiftlint:disable multiple_closures_with_trailing_closure
struct AddLinkView: View {

    @EnvironmentObject var store: AppStore
    // MARK: TODO create own type
    @State var linktype: Int = 0

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker(selection: self.$linktype, label: Text("Linktype")) {
                        Text("Vergleichen").tag(LinkType.compare.rawValue)
                        Text("Summieren").tag(LinkType.sum.rawValue)
                            .onDisappear {
                                // set the type on disappear (no better option because of navigation)
                                self.store.send(.newTemplate(action: .links(action:
                                    .setLinkType(type: LinkType(rawValue: self.linktype)!)))
                                )
                                print(self.store.states.newTemplateState.linkState.currentType!)
                            }
                    }
                    if self.linktype == LinkType.compare.rawValue {
                        Text("Hilfstext für Vergleichen:")

                    } else {
                        Text("Hilfstext für Summieren:")
                    }
                }
                if self.linktype == LinkType.compare.rawValue {
                    Section {
                        NavigationLink(destination: RegionsListView(selectionNumber: 1).environmentObject(self.store)) {
                            HStack {
                                Text("1. Vergleicher")
                                    .foregroundColor(.label)
                                Spacer()
                                Text(getImageRegionName(selectionNumber: 1))
                                    .foregroundColor(.secondaryLabel)
                            }
                        }.isDetailLink(false)
                    }
                    Section {
                        NavigationLink(destination: RegionsListView(selectionNumber: 2).environmentObject(self.store)) {
                            HStack {
                                Text("2. Vergleicher")
                                    .foregroundColor(.label)
                                Spacer()
                                Text(getImageRegionName(selectionNumber: 2))
                                    .foregroundColor(.secondaryLabel)
                            }
                        }.isDetailLink(false)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .navigationBarTitle("Neuen Link erstellen", displayMode: .inline)
            .navigationBarItems(leading: self.leadingItem(), trailing: self.trailingItem())
        }
    }

    private func trailingItem() -> some View {
        Button(action: {

        }) {
            Text("Speichern")
        }
    }

    private func leadingItem() -> some View {
        Button(action: {

        }) {
            Text("Abbrechen")
        }
    }

    private func getImageRegionName(selectionNumber: Int) -> String {
        if selectionNumber == 1 {
            guard let id = self.store.states.newTemplateState.linkState.firstSelections?.first
                else { return "" }
            for page in self.store.states.newTemplateState.newTemplate!.pages {
                for region in page.regions where region.id == id {
                    return region.name
                }
            }
        } else {
            guard let id = self.store.states.newTemplateState.linkState.secondSelections?.first
                else { return "" }
            for page in self.store.states.newTemplateState.newTemplate!.pages {
                for region in page.regions where region.id == id {
                    return region.name
                }
            }
        }
        return ""
    }
}

struct AddLinkView_Previews: PreviewProvider {
    static var previews: some View {
        AddLinkView()
            .environmentObject(AppStoreMock.getAppStore())
    }
}
