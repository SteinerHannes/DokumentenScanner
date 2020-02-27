//
//  BackButton.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 27.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

struct BackButtonView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            Image(systemName: "chevron.left").font(.system(size: 23, weight: .semibold, design: .default))
            Text("Zurück")
        }
    }
}

struct BackButtonView_Previews: PreviewProvider {
    static var previews: some View {
        BackButtonView()
    }
}
