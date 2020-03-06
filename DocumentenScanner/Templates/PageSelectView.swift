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
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            ScrollView(.horizontal, showsIndicators: true) {
                if self.appState.currentTemplate != nil {
                    HStack(alignment: .center, spacing: 15) {
                        ForEach(0 ..< (self.appState.currentTemplate!.pages.count)) { index in
                            NavigationLink(destination: CreateTemplateView(index: index)) {
                                Image(uiImage: self.appState.currentTemplate!.pages[index].image)
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
            self.appState.isPageSelectViewPresented = false
            self.appState.reset()
        }) {
            Text("Abbrechen")
        }
    }

    func trailingItem() -> some View {
        Button(action: {
            self.appState.templates.append(self.appState.currentTemplate!)
            self.appState.isPageSelectViewPresented = false
            self.appState.reset()
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
        return PageSelectView().environmentObject(appState)
    }
}
