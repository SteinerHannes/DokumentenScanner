//
//  TemplatesView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 24.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

struct TemplatesView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                List {
                    Section {
                        ForEach(self.appState.templates, id: \.id) { template in
                            VStack {
                                HStack(alignment: .top, spacing: 10) {
                                    Image(uiImage: template.image!)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(minWidth: 0, maxWidth: 88, minHeight: 0, idealHeight: 88, maxHeight: 88)
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(template.name).font(.headline)
                                        Text(template.info).font(.system(size: 13))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Vorlagen", displayMode: .large)
            .navigationBarItems(trailing: self.trailingItem())
            .onAppear {
                self.appState.templates.append(ImageTemplate(attributeList: [], image: UIImage(imageLiteralResourceName: "post")))
                self.appState.templates.append(ImageTemplate(attributeList: [], image: UIImage(imageLiteralResourceName: "klausur1")))
                self.appState.templates.append(ImageTemplate(attributeList: [], image: UIImage(imageLiteralResourceName: "klausur2")))
            }
        }
    }
//    private func leadingItem() -> some View {
//        return Button(action: {
//            self.appState.isCreateTemplateViewPresented = true
//        }) {
//            Text("test")
//        }
//    }
    
    private func trailingItem() -> some View {
        return Button(action: {
            self.appState.isNewTemplateViewPresented = true
        }) {
            Text("Neue Vorlage")
        }
    }
    
    struct ModalDetail: Identifiable {
        var id: String {
            return body
        }
        
        let body: String
    }
}

struct TemplatesView_Previews: PreviewProvider {
    static var previews: some View {
        TemplatesView().environmentObject(AppState())
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
