//
//  AddControllMachanismView.swift
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
struct AddControllMachanismView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>
    @State var controltype: Int = 0
    @State var showAlert: AlertIdentifier?

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker(selection: self.$controltype, label: Text("Kontrolltyp")) {
                        Text("Vergleichen").tag(ControlType.compare.rawValue)
                        Text("Gesamtpunkzahl").tag(ControlType.sum.rawValue)
                    }
                    if self.controltype == ControlType.compare.rawValue {
                        VStack(alignment: .leading, spacing: 5) {
                            //swiftlint:disable line_length
                            Text("Wählen Sie zwei zu vergleichende Regionen aus. Diese werden beim Scannen auf Gleichheit überprüft. Sind beide Inhalte identisch kommt keine Fehlermeldung, ansonsten schon.").font(.footnote)
                            //swiftlint:enable line_length
                        }
                    } else {
                        Text("Hilfstext für Summieren:")
                    }
                }
                if self.controltype == ControlType.compare.rawValue {
                    Section {
                        NavigationLink(destination: RegionsListView(selectionNumber: 1)
                                                        .environmentObject(self.store)) {
                            HStack {
                                Text("1. Region")
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
                                Text("2. Region")
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
            .navigationBarTitle("Neue Kontrolle erstellen", displayMode: .inline)
            .navigationBarItems(leading: self.leadingItem(), trailing: self.trailingItem())
            .onDisappear {
                // set the type on disappear (no better option because of navigation)
                self.store.send(.newTemplate(action: .controls(action:
                    .setControlType(type: ControlType(rawValue: self.controltype)!)))
                )
            }
            .alert(item: self.$showAlert) { alert in
                switch alert.id {
                    case .noFirstSelections:
                        return Alert(title: Text("1. Region leer."),
                              message: Text("Füge einen 1. Region hinzu!"),
                              dismissButton: .cancel())
                    case .noSecondSelections:
                        return Alert(title: Text("2. Region leer."),
                                     message: Text("Füge einen 2. Region hinzu!"),
                                     dismissButton: .cancel())
                }
            }
            .onAppear {
                self.store.send(.log(action: .navigation("AddControllMechanismScreen")))
            }
            .onDisappear {
                self.store.send(.log(action: .navigation("ControllMechanismScreen")))
            }
        }
    }

    private func trailingItem() -> some View {
        Button(action: {
            if self.store.states.newTemplateState.controlState.firstSelections == nil {
                self.showAlert = .init(id: .noFirstSelections)
            } else if self.store.states.newTemplateState.controlState.secondSelections == nil {
                self.showAlert = .init(id: .noSecondSelections)
            } else {
                self.store.send(.newTemplate(action: .addControlMechanismToNewTemplate))
                self.presentation.wrappedValue.dismiss()
                self.store.send(.newTemplate(action: .controls(action: .clearControlMechanism)))
            }
        }) {
            Text("Speichern")
        }
    }

    private func leadingItem() -> some View {
        Button(action: {
            self.presentation.wrappedValue.dismiss()
            self.store.send(.newTemplate(action: .controls(action: .clearControlMechanism)))
        }) {
            Text("Abbrechen")
        }
    }

    /// Return the Name of the ImageRegion in the selection
    private func getImageRegionName(selectionNumber: Int) -> String {
        if selectionNumber == 1 {
            guard let id = self.store.states.newTemplateState.controlState.firstSelections?.first
                else { return "" }
            for page in self.store.states.newTemplateState.newTemplate!.pages {
                for region in page.regions where region.id == id {
                    return region.name
                }
            }
        } else {
            guard let id = self.store.states.newTemplateState.controlState.secondSelections?.first
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

struct AddControllMachanismView_Previews: PreviewProvider {
    static var previews: some View {
        AddControllMachanismView()
            .environmentObject(AppStoreMock.getAppStore())
    }
}
