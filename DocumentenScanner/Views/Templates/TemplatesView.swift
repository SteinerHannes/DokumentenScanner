//
//  TemplatesView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 24.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

//swiftlint:disable multiple_closures_with_trailing_closure
struct TemplatesView: View {
    @EnvironmentObject var store: AppStore

    @State var selection: String?

    init() {
        print("init TemplatesView")
    }

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 0) {
                    if self.store.states.teamplates.isEmpty {
                        HStack(alignment: .center, spacing: 0) {
                            Spacer()
                            Text("Keine Vorlagen vorhanden.")
                            Spacer()
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.tertiarySystemFill)
                        .cornerRadius(8)
                        .padding()
                    } else {
                        ForEach(self.store.states.teamplates, id: \.id) { template in
                            NavigationLink(destination: TemplateDetailView(),
                                           tag: template.id,
                                           selection: self.$selection) {
                                Button(action: {
                                    self.selection = template.id
                                    self.store.send(.setCurrentTemplate(id: template.id))
                                }) {
                                    TemplateView(template: template)
                                }
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.tertiarySystemFill)
                            .cornerRadius(8)
                            .padding()
                        }
                    }
                }
                .navigationBarTitle("Vorlagen", displayMode: .large)
                .navigationBarItems(trailing: self.trailingItem())
                .navigationBarHidden(self.store.states.routes.isCameraPresented)
            }
        }
    }

    private func trailingItem() -> some View {
        return NavigationLink(destination: NewTemplateView()) {
            Text("Neue Vorlage")
        }
    }
}

private struct TemplateView: View {

    var template: Template

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(alignment: .top, spacing: 10) {
                Image(uiImage: template.pages.first?.image ?? UIImage(imageLiteralResourceName: "test"))
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88, height: 88)
                    .layoutPriority(1)
                VStack(alignment: .leading, spacing: 5) {
                    Text(template.name).font(.headline)
                        .lineLimit(1)
                    Text(template.info).font(.system(size: 13))
                        .lineLimit(4)
                }
                .layoutPriority(1)
                Spacer().frame(minWidth: 0, maxWidth: .infinity)
                Image(systemName: "chevron.right")
                    .frame(width: nil, height: 88, alignment: .trailing)
                    .font(.system(size: 13, weight: .semibold, design: .default))
                    .foregroundColor(.systemFill)
                    .layoutPriority(1)
            }.frame(height: 88)
        }.foregroundColor(.label)
    }
}

struct TemplatesView_Previews: PreviewProvider {
    static var previews: some View {
        TemplatesView()
            .environmentObject(AppStoreMock.getAppStore())
    }
}
