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
    @State var name:String = ""
    @State var datatype:Int = 0
    @State var isShowingSelectRegionView:Bool = false
    @State var isShowingAlert:Bool = false
    
    var body: some View {
        VStack{
            NavigationLink(destination: SelectRegionView(), isActive: self.$isShowingSelectRegionView) {
                EmptyView()
            }
            Form {
                Section {
                    TextField("Name", text: self.$name)
                        .keyboardType(.alphabet)
                    Picker(selection: $datatype, label: Text("Datentyp")) {
                        List {
                            Text("Unbekannt").tag(0)
                            Text("Note").tag(1)
                            Text("Name").tag(2)
                        }
                    }
                }
                Section {
                    Button(action: {
                        if (self.name.isEmpty){
                            self.isShowingAlert = true
                        }else{
                            self.isShowingSelectRegionView = true
                            self.appState.currentAttribut = ImageAttribute(name: self.name, datatype: self.datatype)
                        }
                    }) {
                        Text("Bereich auswählen")
                    }.alert(isPresented: self.$isShowingAlert) {
                        Alert(title: Text("Name ist leer"), message: Text("Setze einen Namen bevor du fortfährst"), dismissButton: .cancel(Text("Ok")) )
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .navigationBarTitle("Eigenschaften festlegen")
        }
    }
}

struct NewAttributView_Previews: PreviewProvider {
    static var previews: some View {
        NewAttributView().environmentObject(AppState())
    }
}
