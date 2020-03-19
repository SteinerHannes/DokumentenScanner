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

    @State var name: String = ""
    @State var info: String = ""
    @State var showCamera: Bool = false
    @State var showAlert: Bool = false

    init() {
        print("init NewTemplateView")
    }

    var body: some View {
        NavigationView {
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
                                self.store.send(.newTemplate(action:
                                    .createNewTemplate(name: self.name, info: self.info))
                                )
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
                        self.store.send(.newTemplate(action: .addPagesToNewTemplate(pages: pages!)))
                        self.store.send(.routing(action: .showPageSelectView))
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
                self.store.send(.routing(action: .showContentView))
            }
        }) {
            BackButtonView()
        }
    }
}

struct NewTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        NewTemplateView()
            .environmentObject(AppStoreMock.getAppStore())
    }
}
