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
    /// The selected ImageRegions
    @State var selections: [ImageRegion] = []
    /// The first or the second selection
    let selectionNumber: Int

    var body: some View {
        List {
            ForEach(0 ..< self.store.states.newTemplateState.newTemplate!.pages.count) { index in
                Section(header: Text("Seite \(index+1)")) {
                    //swiftlint:disable line_length
                    ForEach(0 ..< self.store.states.newTemplateState.newTemplate!.pages[index].regions.count) { regionIndex in
                        RowContainer(region: self.getRegion(for: index, and: regionIndex),
                                     selections: self.$selections,
                                     controltype: self.store.states.newTemplateState.controlState.currentType!)
                    }
                    //swiftlint:enable line_length
                    if self.store.states.newTemplateState.newTemplate!.pages[index].regions.isEmpty {
                        HStack(alignment: .center, spacing: 0) {
                            Spacer()
                            Text("Keine Regionen auf der Seite.")
                            Spacer()
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("Region auswählen", displayMode: .inline)
        .onDisappear {
            self.sendSelection()
        }
        .onAppear {
            self.store.send(.log(action: .navigation("RegionListScreen")))
        }
        .onAppear {
            self.getSelection()
        }
        .navigationBarItems(trailing: StartStopButton())
    }

    /// Returns an ImageRegion for the pagenumber and index of the region
    /// - parameter page: The page number
    /// - parameter region: The index of the region in the page.regions list
    /// - returns: An ImageRegion
    private func getRegion(for page: Int, and region: Int) -> ImageRegion {
        return store.states.newTemplateState.newTemplate!.pages[page].regions[region]
    }

    /// Adds the selection into the store
    private func sendSelection() {
        if self.selectionNumber == 1 {
            self.store.send(
                .newTemplate(action:
                    .controls(action:
                        .setFirstSelections(selections: self.selections.map({ (region) -> String in
                            region.id
                        }))
                    )
                )
            )
        } else {
            self.store.send(
                .newTemplate(action:
                    .controls(action:
                        .setSecondSelections(selections: self.selections.map({ (region) -> String in
                            region.id
                        }))
                    )
                )
            )
        }
    }

    /// Sets the selection to the previous selected regions
    private func getSelection() {
        if self.selectionNumber == 1 {
            guard let id = self.store.states.newTemplateState.controlState.firstSelections?.first
                else { return }
            for page in self.store.states.newTemplateState.newTemplate!.pages {
                for region in page.regions where region.id == id {
                    self.selections.append(region)
                }
            }
        } else {
            guard let id = self.store.states.newTemplateState.controlState.secondSelections?.first
                else { return }
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

    let controltype: ControlType

    let region: ImageRegion

    init(region: ImageRegion, selections: Binding<[ImageRegion]>, controltype: ControlType) {
        self.region = region
        _selections = selections
        self.controltype = controltype
    }

    var body: some View {
        MultipleSelectionRow(region: self.region, isSelected: self.selections.contains(self.region)) {
            switch self.controltype {
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

    let region: ImageRegion
    var isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack(alignment: .center, spacing: 0) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(self.region.name)
                        .foregroundColor(.label)
                    Text(self.region.datatype.getName())
                        .font(.footnote)
                        .foregroundColor(.secondaryLabel)
                }
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
