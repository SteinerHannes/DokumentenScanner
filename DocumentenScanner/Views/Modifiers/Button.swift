//
//  Button.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 30.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

struct PrimaryButton: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    let title: String

    var body: some View {
        Text(title.uppercased())
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .cornerRadius(12)
            .shadow(color: self.colorScheme == .light ? .shadow : .clear, radius: 15, x: 0, y: 5)
    }
}

struct SecondaryButton: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    let title: String

    var body: some View {
        Text(title.uppercased())
            .fontWeight(.bold)
            .foregroundColor(.accentColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: self.colorScheme == .light ? .shadow : .clear, radius: 15, x: 0, y: 5)
    }
}

struct Button_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PrimaryButton(title: "Primary")
                .previewLayout(.fixed(width: 300, height: 100))
            SecondaryButton(title: "Secondary")
                .previewLayout(.fixed(width: 300, height: 100))
        }
    }
}
