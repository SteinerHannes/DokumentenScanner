//
//  CreateTemplateView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 24.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import Foundation

struct CreateTemplateView: View {
    @EnvironmentObject var appState:AppState
    
    @State var isBottomSheetOpen:Bool = true
    @State var isNewAttributViewOpen:Bool = false
    @State var maxHeight:CGFloat = 140
    @State var attributList:[ImageAttribute] = []
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 0) {
                    Image(uiImage: self.appState.image ?? UIImage(imageLiteralResourceName:"post"))
                           .resizable()
                           .scaledToFit()
                    Spacer()
                    NavigationLink(destination: NewAttributView(), isActive: $isNewAttributViewOpen) {EmptyView()}
                }
                BottomSheetView(isOpen: self.$isBottomSheetOpen, maxHeight: self.$maxHeight) {
                    List {
                        Section {
                            Button(action: {
                                self.isNewAttributViewOpen = true
                            }) {
                                Text("Neues Attribut hinzufügen")
                            }
                        }
                        Section {
                            ForEach(self.attributList, id: \.id) { attribut in
                                Text(attribut.name)
                            }
                        }
                    }
                    .listStyle(GroupedListStyle())
                    .environment(\.horizontalSizeClass, .regular)
                }.edgesIgnoringSafeArea(.bottom)
                .navigationBarItems(leading: cancelButton(), trailing: saveButton())
            }.navigationBarTitle("Attribute hinzufügen", displayMode: .inline)
        }
    }
    
    func cancelButton() -> some View {
        return Button(action: {
            self.appState.isCreateTemplateViewPresented = false
        }) {
            Text("Abbrechen")
        }
    }
    
    func saveButton() -> some View {
        return Button(action: {
            self.appState.isCreateTemplateViewPresented = false
        }) {
            Text("Speichern")
        }
    }
}

struct CreateTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        CreateTemplateView().environmentObject(AppState())//(image: .constant(UIImage()))
    }
}
