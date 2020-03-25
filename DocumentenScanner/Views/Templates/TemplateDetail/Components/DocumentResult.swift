//
//  DocumentResult.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 24.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
//swiftlint:disable all line_length unused_closure_parameter
struct DocumentResult: View {
    @EnvironmentObject var store: AppStore

    let template: Template

    var body: some View {
        ForEach(self.template.pages.indexed(), id: \.1.id) { idx, page in
            VStack(alignment: .leading, spacing: 5) {
                Text("Seite \(idx+1) von \(self.template.pages.count)")
                    .font(.headline)
                    .lineLimit(1)
                Text("Regionen: \(self.regionInfo(index: idx))")
                    .font(.system(size: 13))
                    .lineLimit(4)
                ForEach(page.regions.indexed() , id: \.1.id) { ind, region in
                    VStack(alignment: .leading, spacing: 4) {
                        Divider()
                        HStack(alignment: .center, spacing: 0) {
                            Text("\(region.name):")
                            Spacer()
                            Text(self.getConfidence(page: idx, region: ind))
                        }
                        if self.store.states.result.isEmpty {
                            Text("-")
                                .foregroundColor(.secondaryLabel)
                        } else {
                            if !self.store.states.result[idx]!.isEmpty {
                                TextField("\(region.name)", text: Binding<String>(
                                    get: {
                                        return self.store.states.result[idx]![ind].textResult
                                    },
                                    set: { (string) in
                                        self.store.send(.setResult(page: idx, region: ind, text: string))
                                    }
                                ))
                            } else {
                                HStack(alignment: .center, spacing: 0) {
                                    Spacer()
                                    ActivityIndicator(isAnimating: true)
                                        .configure { $0.color = .tertiaryLabel }
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.tertiarySystemFill)
            .cornerRadius(8)
            .padding()
        }
    }
    
    fileprivate func getConfidence(page: Int, region: Int) -> String {
        if self.store.states.result.isEmpty {
            return "-"
        }
        if self.store.states.result[page] == nil || self.store.states.result[page]!.isEmpty {
            return "-"
        } else {
            return String(format: "%.3G", self.store.states.result[page]![region].confidence as Float)
        }
    }
    
    /**
     The functions returns a list of region/attribute names of the page
     */
    fileprivate func regionInfo(index: Int) -> String {
        if self.template.pages[index].regions.isEmpty {
            return "-"
        }
        return self.template.pages[index].regions.map({ (regeion) -> String in
            return regeion.name
        }).joined(separator: ", ")
    }

    /**
     The function returns some page number information
     */
    fileprivate func pageInfo(index: Int) -> String {
        return "Seite \(index+1) von \(self.template.pages.count)"
    }
}

struct DocumentResult_Previews: PreviewProvider {
    static var previews: some View {
        DocumentResult(template: AppStoreMock.getTemplate())
            .environmentObject(AppStoreMock.getAppStore())
    }
}
