//
//  RegionsListView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 17.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

struct RegionsListView: View {
    @EnvironmentObject var store: AppStore

    @State var selections: [ImageRegion] = []

    let selectionNumber: Int

    var body: some View {
        List {
            ForEach(0 ..< self.store.states.newTemplateState.newTemplate!.pages.count) { index in
                Section(header: Text("Seite \(index+1)")) {
                    //swiftlint:disable line_length
                    ForEach(0 ..< self.store.states.newTemplateState.newTemplate!.pages[index].regions.count) { regionIndex in
                    //swiftlint:enable line_length
                        RowContainer(region: self.getRegion(for: index, and: regionIndex),
                                     selections: self.$selections,
                                     linktype: self.store.states.newTemplateState.linkState.currentType!)
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("Region auswählen", displayMode: .inline)
        .onDisappear {
            self.sendSelection()
        }.onAppear {
            self.getSelection()
        }
    }

    private func getRegion(for page: Int, and region: Int) -> ImageRegion {
        return store.states.newTemplateState.newTemplate!.pages[page].regions[region]
    }

    private func sendSelection() {
        if self.selectionNumber == 1 {
            self.store.send(
                .newTemplate(action:
                    .links(action:
                        .setFirstSelections(selections: self.selections.map({ (region) -> String in
                            region.id
                        }))
                    )
                )
            )
        } else {
            self.store.send(
                .newTemplate(action:
                    .links(action:
                        .setSecondSelections(selections: self.selections.map({ (region) -> String in
                            region.id
                        }))
                    )
                )
            )
        }
    }

    private func getSelection() {
        if self.selectionNumber == 1 {
            let id = self.store.states.newTemplateState.linkState.firstSelections?.first
            for page in self.store.states.newTemplateState.newTemplate!.pages {
                for region in page.regions where region.id == id {
                    self.selections.append(region)
                }
            }
        } else {
            let id = self.store.states.newTemplateState.linkState.secondSelections?.first
            for page in self.store.states.newTemplateState.newTemplate!.pages {
                for region in page.regions where region.id == id {
                    self.selections.append(region)
                }
            }
        }
    }
}

struct RowContainer: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>

    @Binding var selections: [ImageRegion]

    let linktype: LinkType

    let region: ImageRegion

    init(region: ImageRegion, selections: Binding<[ImageRegion]>, linktype: LinkType) {
        self.region = region
        _selections = selections
        self.linktype = linktype
    }

    var body: some View {
        MultipleSelectionRow(title: self.region.name, isSelected: self.selections.contains(self.region)) {
            switch self.linktype {
                case .compare:
                    // only one is selected
                    if self.selections.isEmpty {
                        self.selections.append(self.region)
                    } else {
                        self.selections.removeAll()
                        self.selections.append(self.region)
                    }
                    self.presentation.wrappedValue.dismiss()
                default:
                    print("...")
            }
        }
    }

}

struct MultipleSelectionRow: View {
    @EnvironmentObject var store: AppStore

    let title: String
    var isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(self.title)
                    .foregroundColor(.label)
                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .font(.system(size: 15, weight: .semibold, design: .default))
                }
            }
        }
    }
}

struct RegionsListView_Previews: PreviewProvider {
    static var previews: some View {
        RegionsListView(selectionNumber: 1)
            .environmentObject(AppStoreMock.getAppStore())
    }
}
