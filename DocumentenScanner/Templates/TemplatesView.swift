//
//  TemplatesView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 24.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

struct TemplatesView: View {
    @EnvironmentObject var appState:AppState
    
    @State private var isShowingScannerSheet = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                Image(uiImage: self.appState.image ?? UIImage())
                    .resizable()
                    .scaledToFit()
            }
            .navigationBarTitle("Vorlagen", displayMode: .large)
            .navigationBarItems(leading: self.leadingItem(), trailing: self.trailingItem())
            .sheet(isPresented: self.$isShowingScannerSheet) {
                TemplateScannerView(completion: { oriImage in
                    guard oriImage != nil else { return }
                    self.appState.image = oriImage!
                    self.isShowingScannerSheet = false
                    self.appState.isCreateTemplateViewPresented = true
                }).edgesIgnoringSafeArea(.bottom)
            }
        }
    }
    private func leadingItem() -> some View {
        return Button(action: {
            self.appState.isCreateTemplateViewPresented = true
        }) {
            Text("test")
        }
    }
    
    private func trailingItem() -> some View {
        return Button(action: {
            self.openCamera()
        }) {
            //Image(systemName: "plus")
            Text("Vorlage")
        }
    }
    
    private func openCamera() {
        self.isShowingScannerSheet = true
    }
    
    struct ModalDetail: Identifiable {
        var id:String {
            return body
        }
        
        let body:String
    }
}

struct TemplatesView_Previews: PreviewProvider {
    static var previews: some View {
        TemplatesView()
    }
}

//            .sheet(isPresented: self.$isShowingScannerSheet) {
//                TemplateScannerView(completion: { oriImage in
//                    guard oriImage != nil else { return }
//                    self.image = oriImage
//                    self.isShowingScannerSheet = false
//                    self.isShowingEditSheet = true
//                })
//            }
//            .sheet(isPresented: self.$isShowingEditSheet) {
//                CreateTemplateView(image: self.$image)
//            }
