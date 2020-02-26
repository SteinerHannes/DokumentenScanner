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
            .navigationBarItems(trailing: self.trailingItem())
            .sheet(isPresented: self.$isShowingScannerSheet) {
                TemplateScannerView(completion: { oriImage in
                    guard oriImage != nil else { return }
                    self.appState.image = oriImage!
                    self.appState.isCreateTemplateViewPresented = true
                    self.isShowingScannerSheet = false
                }).edgesIgnoringSafeArea(.bottom)
            }
        }
    }
    
    private func trailingItem() -> some View {
        return Button(action: {
            self.openCamera()
        }) {
            Image(systemName: "plus")
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
