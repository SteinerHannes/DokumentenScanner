//
//  TemplatesView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 24.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

struct TemplatesView: View {
    @State private var isShowingScannerSheet = false
    @State private var image:UIImage? = nil
    @State private var isShowingEditSheet = false
    
    @State private var sheetView:ModalDetail?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                Image(uiImage: image ?? UIImage())
                    .resizable()
                    .scaledToFit()
            }
            .navigationBarTitle("Vorlagen", displayMode: .large)
            .navigationBarItems(trailing: self.trailingItem())
            .sheet(item: self.$sheetView) { (detail) in
                    self.modal(detail: detail.body)
            }
        }
    }
    
    private func modal(detail:String) -> some View {
        if(detail == "1"){
            return AnyView(TemplateScannerView(completion: { oriImage in
                guard oriImage != nil else { return }
                self.image = oriImage
                self.sheetView = ModalDetail(body: "2")
            }))
        }else if(detail == "2"){
            return AnyView(CreateTemplateView())//(image: self.$image))
        }
        return AnyView(EmptyView())
    }
    
    private func trailingItem() -> some View {
        return Button(action: {
            self.openCamera()
        }) {
            Image(systemName: "plus")
        }
    }
    
    private func openCamera() {
        self.sheetView = ModalDetail(body: "1")
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
