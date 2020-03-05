//
//  NewTemplateView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 27.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

struct NewTemplateView: View {
    @EnvironmentObject var appState: AppState
    
    @State var name: String = ""
    @State var info: String = ""
    @State var showCamera: Bool = false
    @State var showAlert: Bool = false
    
    init(){
        print("init NewTemplateView")
    }
    
    var body: some View {
        NavigationView{
            ZStack {
                Form {
                    Section {
                        TextField("Name", text: self.$name)
                        TextField("Info", text: self.$info)
                    }
                    Section {
                        Button(action: {
                            if self.name.isEmpty {
                                // MARK: Alert -> showAlert
                            } else {
                                var template = Template()
                                template.name = self.name
                                template.info = self.info
                                self.appState.currentTemplate = template
                                UIApplication.shared.endEditing(true)
                                self.showCamera = true
                            }
                        }) {
                            HStack {
                                Text("Foto aufnehmen")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold, design: .default))
                                    .foregroundColor(.systemFill)
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .environment(\.horizontalSizeClass, .regular)
                .navigationBarTitle("Template hinzufügen", displayMode: .inline)
                .resignKeyboardOnDragGesture()
                
                if self.showCamera {
                    ScannerView(isActive: self.$showCamera, completion: { pages in
                        guard pages != nil else { return }
                        self.appState.currentTemplate!.pages = pages!
                        self.appState.isNewTemplateViewPresented = false
                        self.appState.isPageSelectViewPresented = true
                    })
                        .edgesIgnoringSafeArea(.all)
                }
            }
            .navigationBarItems(leading: backButton())
            .navigationBarHidden(self.showCamera)
        }
    }
    
    private func backButton() -> some View {
        return Button(action: {
            if !self.name.isEmpty {
                self.showAlert = true
            } else {
                self.appState.cleanCurrentImageTemplate()
                self.appState.isNewTemplateViewPresented = false
            }
        }) {
            BackButtonView()
        }
    }
}

struct NewTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewTemplateView()
        }
    }
}
