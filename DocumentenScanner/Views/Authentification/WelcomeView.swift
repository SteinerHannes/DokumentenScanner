//
//  WelcomeView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 30.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {
    let motivation: String = """
        Melde dich an
        oder erstelle einen Account,
        bervor es losgeht.
        """

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Spare kostbare Zeit beim Kontrollieren.")
                    .font(Font.largeTitle.weight(.bold))
                    .foregroundColor(.accentColor)
                    .padding(.horizontal)
                VStack(alignment: .center) {
                    Spacer()
                    Text(self.motivation)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(width: UIScreen.main.bounds.width)
                VStack(spacing: 30) {
                    NavigationLink(destination: LoginView()) {
                        PrimaryButton(title: "Anmelden")
                    }
                    NavigationLink(destination: EmptyView()) {
                        SecondaryButton(title: "Registrieren")
                    }
                }
                .padding([.horizontal, .bottom])
                .padding(.top, 40)
            }
            .navigationBarTitle("Wilkommen!")
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
