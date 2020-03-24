//
//  AddLinkView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 17.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

struct AlertIdentifier: Identifiable {
    enum AlertType {
        case noFirstSelections
        case noSecondSelections
    }

    var id: AlertType
}

//swiftlint:disable multiple_closures_with_trailing_closure
struct AddLinkView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>
    @State var linktype: Int = 0
    @State var showAlert: AlertIdentifier?

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker(selection: self.$linktype, label: Text("Linktype")) {
                        Text("Vergleichen").tag(LinkType.compare.rawValue)
                        Text("Summieren").tag(LinkType.sum.rawValue)
                    }
                    if self.linktype == LinkType.compare.rawValue {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Vergleichen: ")
                            //swiftlint:disable line_length
                            Text("Wählen Sie zwei zu vergleichende Regionen aus. Diese werden beim Scannen auf Gleichheit überprüft. Sind beide Inhalte identisch kommt keine Fehlermeldung, ansonsten schon.").font(.footnote)
                            //swiftlint:enable line_length
                        }
                    } else {
                        Text("Hilfstext für Summieren:")
                    }
                }
                if self.linktype == LinkType.compare.rawValue {
                    Section {
                        NavigationLink(destination: RegionsListView(selectionNumber: 1)
                                                        .environmentObject(self.store)) {
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
                        NavigationLink(destination: RegionsListView(selectionNumber: 2)
                                                        .environmentObject(self.store)) {
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
            .onDisappear {
                // set the type on disappear (no better option because of navigation)
                self.store.send(.newTemplate(action: .links(action:
                    .setLinkType(type: LinkType(rawValue: self.linktype)!)))
                )
            }
            .alert(item: self.$showAlert) { alert in
                switch alert.id {
                    case .noFirstSelections:
                        return Alert(title: Text("1. Vergleicher leer."),
                              message: Text("Füge einen 1. Verlgiecher hinzu!"),
                              dismissButton: .cancel())
                    case .noSecondSelections:
                        return Alert(title: Text("2. Vergleicher leer."),
                                     message: Text("Füge einen 2. Verlgiecher hinzu!"),
                                     dismissButton: .cancel())
                }
            }
        }
    }

    private func trailingItem() -> some View {
        Button(action: {
            if self.store.states.newTemplateState.linkState.firstSelections == nil {
                self.showAlert = .init(id: .noFirstSelections)
            } else if self.store.states.newTemplateState.linkState.secondSelections == nil {
                self.showAlert = .init(id: .noSecondSelections)
            } else {
                self.store.send(.newTemplate(action: .addLinkToNewTemplate))
                self.presentation.wrappedValue.dismiss()
                self.store.send(.newTemplate(action: .links(action: .clearLink)))
            }
        }) {
            Text("Speichern")
        }
    }

    private func leadingItem() -> some View {
        Button(action: {
            self.presentation.wrappedValue.dismiss()
            self.store.send(.newTemplate(action: .links(action: .clearLink)))
        }) {
            Text("Abbrechen")
        }
    }

    /// Return the Name of the ImageRegion in the selection
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
