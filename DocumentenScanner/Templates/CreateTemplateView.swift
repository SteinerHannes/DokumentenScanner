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
    @EnvironmentObject var appState: AppState
    
    @State var isBottomSheetOpen: Bool = true
    @State var isSaveAlertPresented: Bool = false
    
//    init() {
//        UITableView.appearance().backgroundColor = .clear // tableview background
//        //UITableViewCell.appearance().backgroundColor = .clear // cell background
//    }
    
    private var scale: CGFloat {
        if self.appState.image?.size.width ?? 1 <= self.appState.image?.size.height ?? 1 {
            return (UIScreen.main.bounds.width / (self.appState.image?.size.width ?? 1 ))
        }else{
            return (UIScreen.main.bounds.height / (self.appState.image?.size.height ?? 1 ))
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    Image(uiImage: self.appState.image ?? UIImage(imageLiteralResourceName: "post")).frame(alignment: .topLeading)
                    .shadow(color: Color.init(hue: 0, saturation: 0, brightness: 0.7), radius: 20, x: 0, y: 0)
                    ForEach(self.appState.attributList) { attribut in
                        Rectangle()
                            .frame(width: attribut.width, height: attribut.height, alignment: .topLeading)
                            .offset(attribut.rectState)
                            .foregroundColor(Color.gray.opacity(0.9))
                            .overlay(AttributeNameTag(name: attribut.name)
                                .frame(width: attribut.width, height: attribut.height)
                                .offset(attribut.rectState)
                        )
                    }
                }.scaleEffect(self.scale)
                Spacer()
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            
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
                                .contextMenu {
                                    Button(action: {
                                        self.deleteAttribute(for: attribut.id)
                                    }) {
                                        // MARK: no effect
                                        Text("Löschen").font(.system(size: 15))
                                        Image(systemName: "trash").font(.system(size: 15))
                                            .foregroundColor(.red)
                                    }
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .environment(\.horizontalSizeClass, .regular)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .navigationBarTitle("Attribute hinzufügen", displayMode: .inline)
        .navigationBarItems(leading: cancelButton(), trailing: saveButton())
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
    
    func deleteAttribute(for id: String){
        if let index = self.appState.attributList.firstIndex(where: { $0.id == id }) {
            self.appState.attributList.remove(at: index)
        }
        if self.appState.maxHeight > 140{
            self.appState.maxHeight -= 45
        }
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
//
//                print(self.appState.templates[0].attributeList[0])
//                print(self.appState.templates[0].image!.size)
//                UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil);
//
            } else {
                self.isSaveAlertPresented = true
            }
        }) {
            Text("Speichern")
        }
        .alert(isPresented: self.$isSaveAlertPresented) {
            Alert(title: Text("Keine Attribute"), message: Text("Es wurden noch keine Attribute auf diesem Bild hinzugefügt."), primaryButton: .cancel(), secondaryButton: .default(Text("asd")))
        }
    }
}

fileprivate struct AttributeNameTag: View {
    let name: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            GeometryReader { proxy in
                Text(self.name)
                    .font(Font.system(size: 100))
                    .minimumScaleFactor(0.001)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 3)
            }
            .frame(alignment: .topTrailing)
        }
    }
}

struct CreateTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        let image = UIImage(imageLiteralResourceName: "test")
        let appState = AppState()
        appState.image = image
        
        return NavigationView {
            CreateTemplateView().environmentObject(appState)
        }
    }
}
