//
//  NewAttributView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 26.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

//swiftlint:disable multiple_closures_with_trailing_closure
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
                    TextField("Name", text: self.$name)
                        .keyboardType(.alphabet)
                    Picker(selection: $datatype, label: Text("Datentyp")) {
                        Text("Unbekannt").tag(Int(ResultDatatype.none.rawValue))
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
                        }
// swiftlint:disable line_length
//                        .alert(isPresented: self.$isShowingNextAlert) {
//                            Alert(title: Text("Name ist leer"), message: Text("Setze einen Namen bevor du fortfährst"), dismissButton: .cancel(Text("Ok")) )
//                        }
//                        .simultaneousGesture(TapGesture().onEnded{
//                            if (self.name.isEmpty){
//                                self.isShowingNextAlert = true
//                            }else{
//                                self.appState.currentAttribut = ImageRegion(name: self.name, datatype: self.datatype)
//                            }
//                        })
//                        .simultaneousGesture(LongPressGesture().onEnded{ _ in
//                            if (self.name.isEmpty){
//                                self.isShowingNextAlert = true
//                            }else{
//                                self.appState.currentAttribut = ImageRegion(name: self.name, datatype: self.datatype)
//                            }
//                        })
// swiftlint:enable line_length
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .navigationBarTitle("Eigenschaften festlegen")
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: leadingItem())
            .resignKeyboardOnDragGesture()
        }
    }

    private func leadingItem() -> some View {
        Button(action: {
            if  !self.name.isEmpty {
                self.isShowingBackAlert = true
            } else {
                self.presentation.wrappedValue.dismiss()
                self.store.send(.newTemplate(action: .clearCurrentAttribute))
            }
        }) {
            BackButtonView()
        }.alert(isPresented: self.$isShowingBackAlert) {
            Alert(title: Text("Änderungen verwerfen?"),
                  message: nil,
                  primaryButton: .cancel(Text("Abbrechen")),
                  secondaryButton: .destructive(Text("Ja"), action: {
                    self.presentation.wrappedValue.dismiss()
                    self.store.send(.newTemplate(action: .clearCurrentAttribute))
                  }
                )
            )
        }
    }
}

struct NewAttributView_Previews: PreviewProvider {
    static var previews: some View {
        NewAttributView(showRoot: .constant(false))
            .environmentObject(
                AppStore(initialState: .init(),
                         reducer: appReducer,
                         environment: AppEnviorment()
                )
            )
    }
}
