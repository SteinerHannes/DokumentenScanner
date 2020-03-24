//
//  DocumentResult.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 24.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

struct DocumentResult: View {
    @Binding var result: [[PageRegion]]

    let template: Template

    var body: some View {
        ForEach(0..<self.template.pages.count) { index in
            VStack(alignment: .leading, spacing: 5) {
                Text(self.pageInfo(index: index))
                    .font(.headline)
                    .lineLimit(1)
                Text(self.regionInfo(index: index))
                    .font(.system(size: 13))
                    .lineLimit(4)
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(0..<self.template.pages[index].regions.count) { regionIndex in
                        if index < self.result.count {
                            Divider()
                            if  regionIndex < self.result[index].count {
                                HStack(alignment: .center, spacing: 2.5) {
                                    Text("\(self.result[index][regionIndex].regionName):")
                                        .font(.headline)
                                        .layoutPriority(1.0)
                                    Spacer()
                                    Text(String(format: "%.3G",
                                                self.result[index][regionIndex].confidence))
                                        .layoutPriority(1.0)
                                }
                                TextField("", text: self.$result[index][regionIndex].textResult)
                                    .textFieldStyle(PlainTextFieldStyle())
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

    /**
     The functions returns a list of region/attribute names of the page
     */
    fileprivate func regionInfo(index: Int) -> String {
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
        DocumentResult(result: .constant([]), template: AppStoreMock.getTemplate())
    }
}
