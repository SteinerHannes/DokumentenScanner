//
//  HomeView.swift
//  DokumentenScanner
//
//  Created by Hannes Steiner on 18.07.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//
// swiftlint:disable multiple_closures_with_trailing_closure
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                NavigationLink(destination: ScanOverviewView()) {
                    HStack(alignment: .center, spacing: 5) {
                        Text(String("Neue Scan anlegen").uppercased())
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .cornerRadius(12)
                    .shadow(color: self.colorScheme == .light ? .shadow : .clear, radius: 15, x: 0, y: 5)
                }
                NavigationLink(destination: NewTemplateView()) {
                    HStack(alignment: .center, spacing: 5) {
                        Text(String("Neue Vorlage Anlegen").uppercased()).fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .cornerRadius(12)
                    .shadow(color: self.colorScheme == .light ? .shadow : .clear, radius: 15, x: 0, y: 5)
                }
                NavigationLink(destination: TemplatesView()) {
                    HStack(alignment: .center, spacing: 5) {
                        Text(String("Alle Vorlagen ansehen").uppercased())
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.accentColor)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: self.colorScheme == .light ? .shadow : .clear, radius: 15, x: 0, y: 5)
                }
                Spacer()
            }
            .padding([.horizontal, .vertical])
            .navigationBarTitle(Text("Hauptmenü"))
            .navigationBarItems(leading: leadingItem())
        }
    }

    func leadingItem() -> some View {
        return
            Button(action: {
                self.store.send(.auth(action: .logout))
            }) {
                HStack(alignment: .center, spacing: 5) {
                    Image(systemName: "power").font(.body)
                    Text("Ausloggen")
                }
            }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(AppStoreMock.getAppStore())
            .colorScheme(.light)
    }
}
