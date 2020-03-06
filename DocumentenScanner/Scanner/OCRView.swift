//
//  OCRView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 24.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

//swiftlint:disable multiple_closures_with_trailing_closure
struct OCRView: View {
    @State private var isShowingScannerSheet = false
    @State private var text: String = ""

    init() {
        print("init OCRView")
    }

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                Text(self.text).frame(minWidth: 0, maxWidth: .infinity,
                                      minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            }
            .navigationBarTitle("OCRScanner", displayMode: .large)
            .navigationBarItems(trailing: self.trailingItem())
            .sheet(isPresented: self.$isShowingScannerSheet) {
                OCRScannerView(completion: { textPerPage in
                    if let text = textPerPage?.joined(separator: "\n")
                        .trimmingCharacters(in: .whitespacesAndNewlines) {
                        self.text = text
                    }
                    self.isShowingScannerSheet = false
                })
            }
        }
    }

    private func trailingItem() -> some View {
        return Button(action: {
            self.openCamera()
        }) {
            Image(systemName: "plus")
        }
    }

    private func openCamera() {
        self.isShowingScannerSheet = true
    }
}

struct OCRView_Previews: PreviewProvider {
    static var previews: some View {
        OCRView()
    }
}
