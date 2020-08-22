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
        //print("init NewAttributView")
        self._showRoot = showRoot
    }

    var body: some View {
        if !self.showRoot {
            UIApplication.shared.endEditing(true)
            self.presentation.wrappedValue.dismiss()
        }

        return VStack {
            Form {
                Section {
                    CustomTextField("Name", text: self.$name, isFirstResponder: self.showRoot) {
                        $0.keyboardType = .alphabet
                    }
                    Picker(selection: $datatype, label: Text("Datentyp")) {
                        Text(ResultDatatype.none.getName())
                            .tag(ResultDatatype.none.rawValue)
                        Text(ResultDatatype.mark.getName())
                            .tag(ResultDatatype.mark.rawValue)
                        Text(ResultDatatype.firstname.getName())
                            .tag(ResultDatatype.firstname.rawValue)
                        Text(ResultDatatype.lastname.getName())
                            .tag(ResultDatatype.lastname.rawValue)
                        Text(ResultDatatype.studentNumber.getName())
                            .tag(ResultDatatype.studentNumber.rawValue)
                        Text(ResultDatatype.seminarGroup.getName())
                            .tag(ResultDatatype.seminarGroup.rawValue)
                        Text(ResultDatatype.point.getName())
                            .tag(ResultDatatype.point.rawValue)
                    }
                }
                Section {
                    VStack {
                        NavigationLink(destination: SelectRegionView(showRoot: self.$showRoot)) {
                            Group {
                                Image(systemName: "textbox")
                                    .font(.system(size: 20))
                                Text("Bereich auswählen")
                            }.foregroundColor(.blue)
                        }
                        .isDetailLink(false)
                        .onDisappear {
                            // MARK: TODO onDisappear only in one direction
                            self.store.send( .newTemplate(action:
                                .setAttribute(name: self.name,
                                              datatype: ResultDatatype(rawValue: self.datatype)!))
                            )
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .navigationBarTitle("Eigenschaften festlegen", displayMode: .inline)
            .navigationBarItems(trailing: StartStopButton().environmentObject(self.store))
            .onAppear {
                self.store.send(.log(action: .navigation("NewAttributeScreen")))
            }
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
