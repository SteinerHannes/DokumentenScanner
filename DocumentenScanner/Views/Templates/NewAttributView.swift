//
//  NewAttributView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 26.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

struct NewAttributView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>

    @State var name: String = ""
    @State var datatype: Int = 0
    @State var isShowingNextAlert: Bool = false
    @State var isShowingBackAlert: Bool = false
    @Binding var showRoot: Bool

    init(showRoot: Binding<Bool>) {
        print("init NewAttributView")
        self._showRoot = showRoot
    }

    var body: some View {
        VStack {
            Form {
                Section {
                    CustomTextField(placeholder: "Name", text: self.$name, isFirstResponder: true)
                    Picker(selection: $datatype, label: Text("Datentyp")) {
                        Text("Unbekannt").tag(ResultDatatype.none.rawValue)
                        Text("Note").tag(ResultDatatype.mark.rawValue)
                        Text("Name").tag(ResultDatatype.name.rawValue)
                        Text("Matrikelnummer").tag(ResultDatatype.studentNumber.rawValue)
                        Text("Seminargruppe").tag(ResultDatatype.seminarGroup.rawValue)
                        Text("Punkte").tag(ResultDatatype.point.rawValue)
                    }
                }
                Section {
                    VStack {
                        NavigationLink(destination: SelectRegionView(showRoot: self.$showRoot)) {
                            Text("Bereich auswählen").foregroundColor(.blue)
                        }
                        .isDetailLink(false)
                        .onDisappear {
                            // MARK: TODO onDisappear only in one direction
                            self.store.send( .newTemplate(action:
                                .setAttribute(name: self.name,
                                              datatype: ResultDatatype(rawValue: self.datatype)!))
                            )
                            UIApplication.shared.endEditing(true)
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .navigationBarTitle("Eigenschaften festlegen", displayMode: .inline)
            .resignKeyboardOnDragGesture()
        }
    }
}

struct NewAttributView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewAttributView(showRoot: .constant(false))
                .environmentObject(AppStoreMock.getAppStore())
        }
    }
}
