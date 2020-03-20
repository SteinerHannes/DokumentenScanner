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
                    ForEach(self.store.states.newTemplateState.newTemplate!.links) { link in
                        LinkRow(link: link)
                            .contextMenu {
                                Button(action: {
                                    self.store.send(.newTemplate(action:
                                        .deletLinkFromNewTemplate(linkID: link.id)))
                                }) {
                                    // MARK: no size and color effect
                                    Text("Löschen").font(.system(size: 15))
                                    Image(systemName: "trash").font(.system(size: 15))
                                        .foregroundColor(.red)
                                }
                        }
                    }
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
        }) {
            Text("Speichern")
        }
    }
}

struct LinkRow: View {
    @EnvironmentObject var store: AppStore

    let link: Link

    var body: some View {
        if link.linktype == .compare {
            return VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .center, spacing: 5) {
                    Text("1. Vergleicher:")
                    Spacer()
                    Text(getRegionInfo(for: link.regionIDs[0]))
                        .foregroundColor(.secondaryLabel)
                }
                HStack(alignment: .center, spacing: 5) {
                    Text("2. Vergleicher:")
                    Spacer()
                    Text(getRegionInfo(for: link.regionIDs[1]))
                        .foregroundColor(.secondaryLabel)
                }
            }.eraseToAnyView()
        } else {
            return Text("Comming soon").eraseToAnyView()
        }
    }

    private func getRegionInfo(for id: String) -> String {
        for page in self.store.states.newTemplateState.newTemplate?.pages ?? [] {
            for region in page.regions where region.id == id {
                return "\(region.name) (\(page.id))"
            }
        }
        return ""
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
