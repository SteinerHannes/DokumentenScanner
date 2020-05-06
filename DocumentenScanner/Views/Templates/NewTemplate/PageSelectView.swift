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

    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>

    @State var showInfo: Bool = true

    init() {
        print("init PageSelectView")
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.horizontal, showsIndicators: true) {
                if self.store.states.newTemplateState.newTemplate != nil {
                    HStack(alignment: .center, spacing: 15) {
                        //swiftlint:disable line_length
                        ForEach(0 ..< (self.store.states.newTemplateState.newTemplate!.pages.count)) { index in
                            //swiftlint:enable line_length
                            NavigationLink(destination: TemplatePageView(index: index)) {
                                Image(uiImage:
                                    self.store.states.newTemplateState.newTemplate!.pages[index]._image!
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
            if self.showInfo {
                HStack(alignment: .center, spacing: 10) {
                    Text("Wähle eine Seite aus")
                        .font(.callout)
                        .foregroundColor(.secondaryLabel)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Rectangle()
                        .foregroundColor(.quaternarySystemFill)
                        .cornerRadius(8)
                        .transition(.asymmetric(insertion: .scale, removal: .scale))
                )
                .offset(x: 0, y: +40)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
        .navigationBarTitle("\(self.store.states.newTemplateState.newTemplate?.name ?? "Dokument")",
            displayMode: .inline)
        .navigationBarItems(leading: leadingItem(), trailing: trailingItem())
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                withAnimation {
                    self.showInfo = false
                }
            }
        }
    }

    func leadingItem() -> some View {
        Button(action: {
            self.store.send(.routing(action: .showContentView))
            self.store.send(.newTemplate(action: .clearState))
            self.presentation.wrappedValue.dismiss()
        }) {
            Text("Abbrechen")
        }
    }

    func trailingItem() -> some View {
        NavigationLink(destination: ControlMechanismsView()) {
            Text("Weiter")
        }.isDetailLink(false)
    }
}

struct PageSelectView_Previews: PreviewProvider {
    static var previews: some View {
        PageSelectView()
            .environmentObject(AppStoreMock.getAppStore())
    }
}
