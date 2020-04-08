//
//  SectionBackground.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 08.04.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    func sectionBackground() -> some View {
        ModifiedContent(content: self, modifier: SectionBackground())
    }
}

struct SectionBackground: ViewModifier {

    func body(content: Content) -> some View {
        return content
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.tertiarySystemFill)
            .cornerRadius(12)
            .padding(.horizontal)
    }
}
