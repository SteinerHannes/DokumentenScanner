//
//  CreateTemplateView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 24.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import Foundation

//swiftlint:disable multiple_closures_with_trailing_closure
struct TemplatePageView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var store: AppStore

    let index: Int

    @State var isBottomSheetOpen: Bool = true
    @State var maxHeight: CGFloat = 140.0

    private var scale: CGFloat {
        // if the images height is greater then the image width * 16/9 screen size
        if self.store.states.currentTemplate!.pages[self.index].image.size.height >
            self.store.states.currentTemplate!.pages[self.index].image.size.width * (16/9) {
            var tempHeight: CGFloat = 0.0
            if #available(iOS 13.0, *) {
                tempHeight += UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0
            }
            // shrink the image to fit inside the safe area with some padding
            // 10 := beacuse of the bottom sheet indicator
            // 80 := bottom and top padding
            // (screen height - some padding) / image height
            return (UIScreen.main.bounds.height - ((2 * tempHeight) + 10 + 80)) /
                self.store.states.currentTemplate!.pages[self.index].image.size.height
        }
        // screen width / image width
        return UIScreen.main.bounds.width /
            self.store.states.currentTemplate!.pages[self.index].image.size.width
    }

    init(index: Int) {
        print("init CreateTemplateView")
        self.index = index
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    Image(uiImage: self.store.states.currentTemplate!.pages[self.index].image)
                        .frame(alignment: .topLeading)
                        .shadow(color: .shadow, radius: 20, x: 0, y: 0)
                    ForEach(self.store.states.currentTemplate!.pages[self.index].regions) { region in
                        Rectangle()
                            .frame(width: region.width, height: region.height, alignment: .topLeading)
                            .offset(region.rectState)
                            .foregroundColor(Color.gray.opacity(0.9))
                            .overlay(AttributeNameTag(name: region.name)
                                .frame(width: region.width, height: region.height)
                                .offset(region.rectState)
                        )
                    }
                }.scaleEffect(self.scale)
                Spacer()
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)

            BottomSheetView(isOpen: self.$isBottomSheetOpen, maxHeight: self.$maxHeight) {
                List {
                    Section {
                        NavigationLink(destination: NewAttributView(), isActive: self.$appState.showRoot) {
                            Text("Neues Attribut hinzufügen").foregroundColor(.blue)
                        }.isDetailLink(false)
                    }
                    Section {
                        //swiftlint:disable line_length
                        ForEach(self.store.states.currentTemplate!.pages[self.index].regions, id: \.id) { region in
                        //swiftlint:enable line_length
                            Text(region.name)
                                .contextMenu {
                                    Button(action: {
                                        self.deleteAttribute(for: region.id)
                                    }) {
                                        // MARK: no size and color effect
                                        Text("Löschen").font(.system(size: 15))
                                        Image(systemName: "trash").font(.system(size: 15))
                                            .foregroundColor(.red)
                                    }
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .environment(\.horizontalSizeClass, .regular)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .navigationBarTitle("Attribute hinzufügen", displayMode: .inline)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .onAppear {
            // set the image to the current page of the template
            self.appState.image = self.appState.currentTemplate!.pages[self.index].image
            // set the index in the appstate for the child views
            self.appState.currentPage = self.index
            // set the max height to the min(3 , regions in the image)
            self.maxHeight = 140.0 + CGFloat(45 *
                min(self.appState.currentTemplate!.pages[self.appState.currentPage!].regions.count, 3))
        }
    }

    /**
     Delete the attribute in the list of attribute of the current page in the app state
     - parameter id: The unique id of the attribute
     */
    func deleteAttribute(for id: String) {
        // uses the current page number to delete the attribute in the app state
        if let index = self.appState.currentTemplate!.pages[self.index].regions.firstIndex(where: {
            $0.id == id
        }) {
            self.appState.currentTemplate!.pages[self.index].regions.remove(at: index)
            // shrink the height of the bottom sheet, if there are less than 4 itmes in it
            if self.appState.maxHeight > 140 &&
                self.appState.currentTemplate!.pages[self.index].regions.count < 3 {
                self.appState.maxHeight -= 45
            }
        }
    }
}

private struct AttributeNameTag: View {
    let name: String

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            GeometryReader { _ in
                Text(self.name)
                    .font(Font.system(size: 100))
                    .minimumScaleFactor(0.001)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 3)
            }
            .frame(alignment: .topTrailing)
        }
    }
}

struct CreateTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        appState.currentTemplate = Template(id: "0", name: "Bla", info: "Bla",
                                            pages: [Page(id: 0,
                                                         image: UIImage(imageLiteralResourceName: "test"))])

        return NavigationView {
            TemplatePageView(index: 0)
                .environmentObject(appState)
                .environmentObject(
                    AppStore(initialState: .init(),
                             reducer: appReducer,
                             environment: AppEnviorment()
                    )
                )
        }
    }
}