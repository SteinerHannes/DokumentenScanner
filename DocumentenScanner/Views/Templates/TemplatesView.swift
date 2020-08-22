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
    @State private var isShowing = false

    init() {
        //print("init TemplatesView")
    }

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
//                VStack(alignment: .leading, spacing: 10) {
//                    APITestView()
//                }.frame(height: 100)
                VStack(alignment: .leading, spacing: 16) {
                    if self.store.states.teamplates.isEmpty {
                        HStack(alignment: .center, spacing: 0) {
                            Spacer()
                            Text("Keine Vorlagen vorhanden.")
                            Spacer()
                        }
                        .sectionBackground()
                    } else {
                        ForEach(self.store.states.teamplates, id: \.id) { template in
                            NavigationLink(
                                destination:
                                    LazyView(TemplateDetailView(template: template)
                                        .environmentObject(self.store)),
                                tag: template.id,
                                selection: self.$selection) {
                                    Button(action: {
                                        self.store.send(.setCurrentTemplate(id: template.id))
                                        self.selection = template.id
                                        self.store.send(.ocr(action: .clearResult))
                                    }) {
                                        TemplateCard(template: template)
                                    }
                            }
                            .sectionBackground()
                        }
                    }
                }
            }
            .pullToRefresh(isShowing: self.$isShowing, onRefresh: {
                self.store.send(.service(action: .getTemplateList))
                self.isShowing = false
            })
            .navigationBarTitle("Vorlagen", displayMode: .large)
            .navigationBarItems(leading: self.leadingItem(), trailing: self.trailingItem())
            .navigationBarHidden(self.store.states.routes.isCameraPresented)
            .onAppear {
                self.store.send(.log(action: .navigation("TemplateView")))
            }
        }
    }

    private func trailingItem() -> some View {
        return
            HStack(alignment: .center, spacing: 20) {
                NavigationLink(destination: LazyView(NewTemplateView())) {
                    Image(systemName: "plus.square.on.square")
                        .font(.body)
                    Text("Neue Vorlage")
                }
                StartStopButton().environmentObject(self.store)
        }
    }

    private func leadingItem() -> some View {
        return
            Button(action: {
                self.store.send(.auth(action: .logout))
            }) {
                Text("Ausloggen")
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
                    Image(systemName: "photo")
                        .fetchingRemoteImage(from: template.pages.isEmpty ? "" : template.pages[0].url)
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
