//
//  ControlMechanismsView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 17.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

//swiftlint:disable multiple_closures_with_trailing_closure
struct ControlMechanismsView: View {
    @EnvironmentObject var store: AppStore

    @State var isActive: Bool = false

    var body: some View {
        List {
            Section {
                Button(action: {
                    self.isActive = true
                }) {
                    Text("Neuen Kontroll-Mechanismus hinzufügen")
                }
            }
            if self.store.states.newTemplateState.newTemplate?.controlMechanisms.isEmpty ?? true {
                Section {
                    HStack(alignment: .center, spacing: 0) {
                        Spacer()
                        Text("Keine Kontroll-Mechanismus vorhanden.")
                        Spacer()
                    }
                }
            } else {
                Section {
                    ForEach(self.store.states.newTemplateState.newTemplate!.controlMechanisms) { control in
                        ControllMechanismRow(control: control)
                            .contextMenu {
                                Button(action: {
                                    self.store.send(.newTemplate(action:
                                        .deletControlMechanismFromNewTemplate(mechanismID: control.id)))
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
            AddControllMachanismView().environmentObject(self.store)
        }
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("Kontroll-Liste", displayMode: .inline)
        .navigationBarItems(trailing: trailingItem())
    }

    func trailingItem() -> some View {
        Button(action: {
            self.store.send(.addNewTemplate(template: self.store.states.newTemplateState.newTemplate!))
            self.store.send(.routing(action: .showContentView))
//            self.store.send(.newTemplate(action: .clearState))
            self.store.send(.service(action: .createTemplate))
        }) {
            Text("Speichern")
        }
    }
}

struct ControllMechanismRow: View {
    @EnvironmentObject var store: AppStore

    let control: ControlMechanism

    var body: some View {
        if control.controltype == .compare {
            return VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .center, spacing: 5) {
                    Text("1. Region:")
                    Spacer()
                    Text(getRegionInfo(for: control.regionIDs[0]))
                        .foregroundColor(.secondaryLabel)
                }
                HStack(alignment: .center, spacing: 5) {
                    Text("2. Region:")
                    Spacer()
                    Text(getRegionInfo(for: control.regionIDs[1]))
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
                return "\(region.name) (\(page.number))"
            }
        }
        return ""
    }
}

struct ControlMechanismsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ControlMechanismsView()
                .environmentObject(AppStoreMock.getAppStore())
        }
    }
}
