//
//  WelcomeView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 30.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var store: AppStore
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
                    NavigationLink(destination: LoginView().environmentObject(self.store)) {
                        PrimaryButton(title: "Anmelden")
                    }.isDetailLink(false)
                    NavigationLink(destination: RegisterView().environmentObject(self.store)) {
                        SecondaryButton(title: "Registrieren")
                    }.isDetailLink(false)
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
        WelcomeView().environmentObject(AppStoreMock.getAppStore())
    }
}
