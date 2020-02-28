//
//  CreateTemplateView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 24.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import Foundation

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

struct CreateTemplateView: View {
    @EnvironmentObject var appState: AppState
    
    @State var isBottomSheetOpen: Bool = true
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    Image(uiImage: self.appState.image ?? UIImage(imageLiteralResourceName: "post"))
                        .resizable()
                        .scaledToFit()
                    ForEach(self.appState.attributList) { attribut in
                        Rectangle()
                            .frame(width: attribut.width, height: attribut.height)
                            .offset(attribut.rectState)
                    }
                }
                Spacer()
            }
            BottomSheetView(isOpen: self.$isBottomSheetOpen, maxHeight: self.$appState.maxHeight) {
                List {
                    Section {
                        NavigationLink(destination: LazyView(NewAttributView()), isActive: self.$appState.showRoot) {
                            Text("Neues Attribut hinzufügen").foregroundColor(.blue)
                        }.isDetailLink(false)
                    }
                    Section {
                        ForEach(self.appState.attributList, id: \.id) { attribut in
                            Text(attribut.name)
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .environment(\.horizontalSizeClass, .regular)
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarItems(leading: cancelButton(), trailing: saveButton())
        }.navigationBarTitle("Attribute hinzufügen", displayMode: .inline)
    }
    
    func cancelButton() -> some View {
        return Button(action: {
            // MARK: Show Alert
            self.appState.reset()
        }) {
            Text("Abbrechen")
        }
    }
    
    func saveButton() -> some View {
        return Button(action: {
            let list = self.appState.attributList
            let image = self.appState.image
            if !list.isEmpty && image != nil {
                var template = self.appState.currentImageTemplate!
                template.attributeList = list
                template.image = image
                self.appState.templates.append(template)
                self.appState.reset()
            } else {
                // MARK: show Alert
            }
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
