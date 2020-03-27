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
                            NavigationLink(
                                destination:
                                    TemplateDetailView(template: template)
                                        .environmentObject(self.store)
                                , tag: template.id
                                , selection: self.$selection) {
                                    Button(action: {
                                        self.store.send(.setCurrentTemplate(id: template.id))
                                        self.selection = template.id
                                        self.store.send(.clearResult)
                                    }) {
                                        TemplateCard(template: template)
                                    }
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.tertiarySystemFill)
                            .cornerRadius(12)
                            .padding()
                        }
                    }
                }
            }
            .navigationBarTitle("Vorlagen", displayMode: .large)
            .navigationBarItems(trailing: self.trailingItem())
            .navigationBarHidden(self.store.states.routes.isCameraPresented)
        }
    }

    private func trailingItem() -> some View {
        return
            NavigationLink(destination: NewTemplateView()) {
                Image(systemName: "plus.square.on.square")
                    .font(.body)
                Text("Neue Vorlage")
            }
    }
}

private struct TemplateCard: View {
    var template: Template

    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            VStack(alignment: .leading, spacing: 5) {
                Text(template.name)
                    .font(.title)
                    .lineLimit(2)
                HStack(alignment: .top, spacing: 10) {
                    Image(uiImage: template.pages.first?.image ?? UIImage(imageLiteralResourceName: "test"))
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 88, height: 120)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(template.pages.count) \(template.pages.count == 1 ? "Seite" : "Seiten" )")
                            .font(.callout)
                            .foregroundColor(.secondaryLabel)
                        Text(template.info)
                            .font(.body)
                            .lineLimit(4)
                    }
                }.frame(height: 120)
            }
            .foregroundColor(.label)
            .layoutPriority(1)
            Spacer()
                .frame(minWidth: 0, maxWidth: .infinity)
            Image(systemName: "chevron.right")
                .frame(width: nil, height: 88, alignment: .trailing)
                .font(.system(size: 13, weight: .semibold, design: .default))
                .foregroundColor(.systemFill)
                .layoutPriority(1)
        }
    }
}

struct TemplatesView_Previews: PreviewProvider {
    static var previews: some View {
        TemplatesView()
            .environmentObject(AppStoreMock.getAppStore())
    }
}
