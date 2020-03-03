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
                        if self.appState.templates.isEmpty {
                            HStack(alignment: .center, spacing: 0) {
                                Spacer()
                                Text("Keine Vorlagen vorhanden.")
                                Spacer()
                            }
                        }else{
                            ForEach(self.appState.templates, id: \.id) { template in
                                Button(action: {
                                    self.appState.setCurrentImageTemplate(for: template.id)
                                    self.appState.isTemplateDetailViewPresented = true
                                }) {
                                    VStack(alignment: .center, spacing: 0) {
                                        HStack(alignment: .top, spacing: 10) {
                                            Image(uiImage: template.image!)
                                                .renderingMode(.original)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 88, height: 88)
                                                .layoutPriority(1)
                                            VStack(alignment: .leading, spacing: 5) {
                                                Text(template.name).font(.headline)
                                                    .lineLimit(1)
                                                Text(template.info).font(.system(size: 13))
                                                    .lineLimit(4)
                                            }
                                                .layoutPriority(1)
                                            Spacer().frame(minWidth: 0, maxWidth: .infinity)
                                            Image(systemName: "chevron.right")
                                                .frame(width: nil, height: 88, alignment: .trailing)
                                                .font(.system(size: 13, weight: .semibold, design: .default))
                                                .foregroundColor(.systemFill)
                                                .layoutPriority(1)
                                        }.frame(height: 88)
                                    }.foregroundColor(.label)
                                }
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .environment(\.horizontalSizeClass, .regular)
            }
            .navigationBarTitle("Vorlagen", displayMode: .large)
            .navigationBarItems(trailing: self.trailingItem())
//            .onAppear {
//                self.appState.templates.append(ImageTemplate(attributeList: [], image: UIImage(imageLiteralResourceName: "post")))
//                self.appState.templates.append(ImageTemplate(attributeList: [], image: UIImage(imageLiteralResourceName: "klausur1")))
//                self.appState.templates.append(ImageTemplate(attributeList: [], image: UIImage(imageLiteralResourceName: "klausur2")))
//            }
        }
    }
    
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
//                ScannerView(completion: { oriImage in
//                    guard oriImage != nil else { return }
//                    self.image = oriImage
//                    self.isShowingScannerSheet = false
//                    self.isShowingEditSheet = true
//                })
//            }
//            .sheet(isPresented: self.$isShowingEditSheet) {
//                CreateTemplateView(image: self.$image)
//            }
