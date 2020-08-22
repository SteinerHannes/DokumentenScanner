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
    @EnvironmentObject var store: AppStore

    let index: Int

    @State var isBottomSheetOpen: Bool = true
    @State var maxHeight: CGFloat = 140.0
    @State var showRoot: Bool = false

    private var scale: CGFloat {
        let imageHeight =
            self.store.states.newTemplateState.newTemplate!.pages[self.index]._image?.size.height ?? 0
        let imageWidth =
            self.store.states.newTemplateState.newTemplate!.pages[self.index]._image?.size.width ?? 0
        // if the images height is greater then the image width * 16/9 screen size
        if imageHeight > imageWidth * (16/9) {
            var tempHeight: CGFloat = 0.0
            tempHeight += UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0
            // shrink the image to fit inside the safe area with some padding
            // 10 := beacuse of the bottom sheet indicator
            // 80 := bottom and top padding
            // (screen height - some padding) / image height
            return (UIScreen.main.bounds.height - ((2 * tempHeight) + 10 + 80)) / imageHeight
        }
        // screen width / image width
        return UIScreen.main.bounds.width / imageWidth
    }

    init(index: Int) {
        //print("init CreateTemplateView")
        self.index = index
    }

    var body: some View {
        let template = self.store.states.newTemplateState.newTemplate!

        return ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    Image(uiImage: template.pages[self.index]._image!)
                        .frame(alignment: .topLeading)
                        .shadow(color: .shadow, radius: 20, x: 0, y: 0)
                    ForEach(template.pages[self.index].regions) { region in
                        Rectangle()
                            .stroke(Color.label, lineWidth: 3)
                            .background(Color.accentColor.opacity(0.7))
                            .frame(width: region.width, height: region.height, alignment: .topLeading)
                            .offset(region.rectState)
                            .overlay(
                                AttributeNameTag(name: region.name)
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
                        NavigationLink(destination: NewAttributView(showRoot: self.$showRoot),
                                       isActive: self.$showRoot) {
                            Group {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 20))
                                Text("Neue Region hinzufügen")
                            }.foregroundColor(.blue)
                        }.isDetailLink(false)
                    }
                    Section {
                        ForEach(template.pages[self.index].regions, id: \.id) { region in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(region.name)
                                    .foregroundColor(.label)

                                Text(region.datatype.getName())
                                    .foregroundColor(.secondaryLabel)
                                    .font(.system(.callout))
                            }
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
        .navigationBarTitle("Region hinzufügen", displayMode: .inline)
        .navigationBarItems(trailing: StartStopButton().environmentObject(self.store))
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .onAppear {
            self.store.send(.log(action: .navigation("TemplatePageScreen")))
        }
        .onAppear {
            // set the image to the current page of the template and
            // set the index in the appstate for the child views
            self.store.send(.newTemplate(action: .setImageAndPageNumber(number: self.index)))
            // set the max height to the min(3 , regions in the image)
            self.maxHeight = 140.0 + CGFloat(45 *
                min(template.pages[self.index].regions.count, 3))
        }
    }

    /**
     Delete the attribute in the list of attribute of the current page in the app state
     - parameter id: The unique id of the attribute
     */
    func deleteAttribute(for id: String) {
        // uses the current page number to delete the attribute in the app state
        self.store.send(.newTemplate(action: .removeAttribute(id: id)))
        // shrink the height of the bottom sheet, if there are less than 4 itmes in it
        let template = self.store.states.newTemplateState.newTemplate!
        if self.maxHeight > 140 && template.pages[self.index].regions.count < 3 {
            self.maxHeight -= 45
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
        NavigationView {
            TemplatePageView(index: 0)
                .environmentObject(AppStoreMock.getAppStore())
        }
    }
}
