//
//  NewTemplateView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 27.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

//swiftlint:disable multiple_closures_with_trailing_closure
struct NewTemplateView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>

    @State var name: String = ""
    @State var info: String = ""
    @State var showCamera: Bool = false
    @State var showAlert: Bool = false

    init() {
        print("init NewTemplateView")
    }

    var body: some View {
        ZStack {
            Form {
                Section {
                    CustomTextField("Name", text: self.$name, isFirstResponder: true) {
                        $0.keyboardType = .alphabet
                    }
                    TextField("Info", text: self.$info)
                }
                Section {
                    Button(action: {
                        if self.name.isEmpty {
                            self.showAlert = true
                        } else {
                            self.store.send(.routing(action: .turnOnCamera))
                            self.store.send(.newTemplate(action:
                                .createNewTemplate(name: self.name, info: self.info))
                            )
                            UIApplication.shared.endEditing(true)
                            self.showCamera = true
                        }
                    }) {
                        HStack(alignment: .center, spacing: 5) {
                            Image(systemName: "doc.text.viewfinder")
                                .font(.system(size: 24))
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
            .resignKeyboardOnDragGesture()
            .alert(isPresented: self.$showAlert) {
                Alert(title: Text("Die Vorlage hat noch keinen Namen."))
            }

            if self.showCamera {
                ScannerView(isActive: self.$showCamera, completion: { pages in
                    self.store.send(.routing(action: .turnOffCamera))
                    guard pages != nil else { return }
                    self.store.send(.newTemplate(action: .addPagesToNewTemplate(pages: pages!)))
                    self.store.send(.routing(action: .showPageSelectView))
                    self.presentation.wrappedValue.dismiss()
                })
                .edgesIgnoringSafeArea(.all)
            }
        }
        .navigationBarTitle("Vorlage anlegen", displayMode: .inline)
        .navigationBarHidden(self.showCamera)
    }
}

struct NewTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        NewTemplateView()
            .environmentObject(AppStoreMock.getAppStore())
    }
}
