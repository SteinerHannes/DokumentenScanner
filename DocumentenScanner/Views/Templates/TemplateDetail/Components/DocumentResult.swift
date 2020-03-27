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
    
    @State var showSymbole: Bool = true

    let template: Template

    var body: some View {
        ForEach(self.template.pages.indexed(), id: \.1.id) { pageIdx, page in
            VStack(alignment: .leading, spacing: 8) {
                Text("Seite \(pageIdx+1) von \(self.template.pages.count)")
                    .font(.headline)
                    .lineLimit(1)
                Text("\(self.regionInfo(index: pageIdx))")
                    .font(.caption)
                    .lineLimit(4)
                ForEach(page.regions.indexed() , id: \.1.id) { regionIdx, region in
                    VStack(alignment: .leading, spacing: 8) {
                        Divider()
                        HStack(alignment: .center, spacing: 0) {
                            Text("\(region.name):")
                                .bold()
                            Spacer()
                            ConfidenceButton(showSymbole: self.$showSymbole, page: pageIdx, region: regionIdx)
                        }
                        if self.store.states.result.isEmpty {
                            Text("-")
                                .foregroundColor(.secondaryLabel)
                        } else {
                            if !self.store.states.result[pageIdx]!.isEmpty {
                                TextField("\(region.name)", text: Binding<String>(
                                    get: {
                                        return self.store.states.result[pageIdx]![regionIdx].textResult
                                    },
                                    set: { (string) in
                                        self.store.send(
                                            .setResult(page: pageIdx, region: regionIdx, text: string))
                                    }
                                )).keyboardType(self.getKeyboardType(page: pageIdx, region: regionIdx))
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
    
    fileprivate func getKeyboardType(page: Int, region: Int) -> UIKeyboardType {
        switch self.store.states.result[page]?[region].datatype {
            case .mark:
                return .decimalPad
            case .name:
                return .alphabet
            case .point:
                return .decimalPad
            default:
                return .default
        }
    }
    
    /**
     The functions returns a list of region/attribute names of the page
     */
    fileprivate func regionInfo(index: Int) -> String {
        if self.template.pages[index].regions.isEmpty {
            return "Keine Regionen"
        }
        return "Regionen: " + self.template.pages[index].regions.map({ (regeion) -> String in
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

struct ConfidenceButton: View {
    @EnvironmentObject var store: AppStore
    
    @Binding var showSymbole: Bool
    let page: Int
    let region: Int
    
    var body: some View {
        Button(action: {
            self.showSymbole.toggle()
        }) {
            if showSymbole {
                self.getConfidenceCircle(page: page, region: region)
                    .frame(width: 10, height: 10)
            } else {
                Text(self.getConfidence(page: page, region: region))
                    .foregroundColor(.secondaryLabel)
            }
        }
    }
    
    fileprivate func getConfidence(page: Int, region: Int) -> String {
        if self.store.states.result.isEmpty {
            return "-"
        }
        if self.store.states.result[page] == nil || self.store.states.result[page]!.isEmpty {
            return "-"
        } else {
            if self.store.states.result[page]![region].confidence.isNaN {
                return "Kein Ergebnis"
            }
            return String(format: "%.3G", self.store.states.result[page]![region].confidence as Float)
        }
    }
    
    fileprivate func getConfidenceCircle(page: Int, region: Int) -> some View {
        let error = Image(systemName: "exclamationmark.triangle.fill")
            .foregroundColor(.red)
            .eraseToAnyView()
        
        if self.store.states.result.isEmpty {
            return EmptyView().eraseToAnyView()
        }
        if self.store.states.result[page] == nil || self.store.states.result[page]!.isEmpty {
            return EmptyView().eraseToAnyView()
        } else {
            if self.store.states.result[page]![region].confidence.isNaN {
                return error
            }
            let color: Color
            switch self.store.states.result[page]![region].confidence {
                case 0.65...1.0:
                    color = .green
                case 0.35..<0.65:
                    color = .yellow
                case 0.2..<0.35:
                    color = .orange
                default:
                    color = .red
            }
            
            return Circle()
                .frame(width: 10, height: 10)
                .foregroundColor(color)
                .eraseToAnyView()
        }
    }
}

struct DocumentResult_Previews: PreviewProvider {
    static var previews: some View {
        DocumentResult(template: AppStoreMock.getTemplate())
            .environmentObject(AppStoreMock.getAppStore())
    }
}
