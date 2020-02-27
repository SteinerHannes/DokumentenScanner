//
//  NewAttributView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 26.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

struct NewAttributView: View {
    @EnvironmentObject var appState:AppState
    @Environment(\.presentationMode) var presentation:Binding<PresentationMode>
    
    @State var name:String = ""
    @State var datatype:Int = 0
    @State var isShowingNextAlert:Bool = false
    @State var isShowingBackAlert:Bool = false
    
    var body: some View {
        VStack{
            Form {
                Section {
                    TextField("Name", text: self.$name)
                        .keyboardType(.alphabet)
                    Picker(selection: $datatype, label: Text("Datentyp")) {
                        List {
                            Text("Unbekannt").tag(0)
                            Text("Note").tag(1)
                            Text("Name").tag(2)
                            Text("Matrikelnummer").tag(3)
                            Text("Seminargruppe").tag(4)
                        }
                    }
                }
                Section {
                    VStack{
                        NavigationLink(destination: LazyView(SelectRegionView())) {
                            Text("Bereich auswählen").foregroundColor(.blue)
                        }
                        .isDetailLink(false)
                        .onDisappear {
                            self.appState.currentAttribut = ImageAttribute(name: self.name, datatype: self.datatype)
                        }
//                        .alert(isPresented: self.$isShowingNextAlert) {
//                            Alert(title: Text("Name ist leer"), message: Text("Setze einen Namen bevor du fortfährst"), dismissButton: .cancel(Text("Ok")) )
//                        }
//                        .simultaneousGesture(TapGesture().onEnded{
//                            if (self.name.isEmpty){
//                                self.isShowingNextAlert = true
//                            }else{
//                                self.appState.currentAttribut = ImageAttribute(name: self.name, datatype: self.datatype)
//                            }
//                        })
//                        .simultaneousGesture(LongPressGesture().onEnded{ _ in
//                            if (self.name.isEmpty){
//                                self.isShowingNextAlert = true
//                            }else{
//                                self.appState.currentAttribut = ImageAttribute(name: self.name, datatype: self.datatype)
//                            }
//                        })
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .navigationBarTitle("Eigenschaften festlegen")
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: backButton())
            .resignKeyboardOnDragGesture()
        }
    }
    
    private func backButton() -> some View {
        Button(action: {
            if( !self.name.isEmpty){
                self.isShowingBackAlert = true
            }else{
                self.presentation.wrappedValue.dismiss()
            }
        }){
            BackButtonView()
        }.alert(isPresented: self.$isShowingBackAlert) {
            Alert(title: Text("Änderungen verwerfen?"),
                  message: nil,
                  primaryButton: .cancel(Text("Abbrechen")),
                  secondaryButton: .destructive(Text("Ja"), action: {
                    self.presentation.wrappedValue.dismiss()
                  }
                )
            )
        }
    }
}

struct NewAttributView_Previews: PreviewProvider {
    static var previews: some View {
        NewAttributView().environmentObject(AppState())
    }
}
