//
//  PageSelectView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 05.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

//swiftlint:disable multiple_closures_with_trailing_closure
struct PageSelectView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        NavigationView {
            ScrollView(.horizontal, showsIndicators: true) {
                if self.store.states.newTemplateState.newTemplate != nil {
                    HStack(alignment: .center, spacing: 15) {
                        //swiftlint:disable line_length
                        ForEach(0 ..< (self.store.states.newTemplateState.newTemplate!.pages.count)) { index in
                        //swiftlint:enable line_length
                            NavigationLink(destination: TemplatePageView(index: index)) {
                                Image(uiImage:
                                    self.store.states.newTemplateState.newTemplate!.pages[index].image
                                )
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFit()
                                    .shadow(color: .shadow, radius: 5, x: 0, y: 0)
                            }
                            .isDetailLink(false)
                            .frame(maxWidth: UIScreen.main.bounds.width-32,
                                   maxHeight: UIScreen.main.bounds.width)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Document", displayMode: .inline)
            .navigationBarItems(leading: leadingItem(), trailing: trailingItem())
        }

    }

    func leadingItem() -> some View {
        Button(action: {
            self.store.send(.routing(action: .showContentView))
            self.store.send(.newTemplate(action: .clearState))
        }) {
            Text("Abbrechen")
        }
    }

    func trailingItem() -> some View {
        Button(action: {
            self.store.send(.addNewTemplate(template: self.store.states.newTemplateState.newTemplate!))
            self.store.send(.routing(action: .showContentView))
            self.store.send(.newTemplate(action: .clearState))
        }) {
            Text("Speichern")
        }
    }
}

struct PageSelectView_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        let page1 = Page(id: 0, image: UIImage(imageLiteralResourceName: "test"))
        let page2 = Page(id: 1, image: UIImage(imageLiteralResourceName: "post"))
        let page3 = Page(id: 2, image: UIImage(imageLiteralResourceName: "klausur1"))
        let page4 = Page(id: 3, image: UIImage(imageLiteralResourceName: "klausur2"))

        appState.currentTemplate! = Template(id: "0", name: "Klausur",
                                             info: "Infotext", pages: [page1, page2, page3, page4])
        return PageSelectView()
            .environmentObject(
                AppStore(initialState: .init(),
                         reducer: appReducer,
                         environment: AppEnviorment()
                )
        )
    }
}