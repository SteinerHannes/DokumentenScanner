//
//  DocumentLink.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 06.04.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

struct DocumentLink: View {
    @EnvironmentObject var store: AppStore

    let template: Template

    @Binding var links: [String: (Int, Int)]

    let idList: [String: ImageRegion]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Links")
                .font(.headline)
            Text("Anzahl aller Links: \(template.links.count)")
                .font(.caption)
            ForEach(template.links) { link in
                LinkView(links: self.$links, link: link, idList: self.idList)
            }
        }
        .sectionBackground()
    }
}

struct DocumentLink_Previews: PreviewProvider {
    static var previews: some View {
        DocumentLink(template: AppStoreMock.realTemplate(), links: .constant([:]), idList: [:])
            .environmentObject(AppStoreMock.getAppStore())
    }
}

struct LinkView: View {
    @EnvironmentObject var store: AppStore
    @Binding var links: [String: (Int, Int)]

    let link: Link
    let idList: [String: ImageRegion]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            HStack(alignment: .center, spacing: 0) {
                Text(link.linktypeName)
                    .font(.headline)
                Spacer()
            }
            Text(self.getLinkInfo(link: link))
                .font(.subheadline)
            if self.store.states.ocrState.result.isEmpty {
                Text("-")
                    .foregroundColor(.secondaryLabel)
            } else {
                getTypeView(link: link)
            }
        }
    }

    private func getLinkInfo(link: Link) -> String {
        switch link.linktype {
            case .compare:
                let region1 = self.idList[link.regionIDs[0]]
                let region2 = self.idList[link.regionIDs[1]]
                return "\(region1?.name ?? "Fehler") & \(region2?.name ?? "Fehler")"
            case .sum:
                return ""
        }
    }

    private func getTypeView(link: Link) -> some View {
        switch link.linktype {
            case .compare:
                let element1 = links[link.regionIDs[0]]
                let element2 = links[link.regionIDs[1]]
                if element1 == nil || element2 == nil {
                    return Text("Link kann noch nicht überprüft werden.")
                        .eraseToAnyView()
                } else {
                    let region1 = Binding<PageRegion>(
                        get: {
                            return self.store.states.ocrState.result[element1!.0]![element1!.1]
                    },
                        set: { (region) in
                            self.store.send(
                                .ocr(action:
                                    .changeResult(page: element1!.0,
                                                  region: element1!.1,
                                                  text: region.textResult)))
                    }
                    )
                    let region2 = Binding<PageRegion>(
                        get: {
                            return self.store.states.ocrState.result[element2!.0]![element2!.1]
                    },
                        set: { (region) in
                            self.store.send(
                                .ocr(action:
                                    .changeResult(page: element2!.0, region: element2!.1,
                                                  text: region.textResult)))
                    }
                    )
                    return CompareResultView(region1: region1, region2: region2)
                            .eraseToAnyView()
            }
            case .sum:
                return Text("asd")
                    .eraseToAnyView()
        }
    }
}

struct CompareResultView: View {
    @EnvironmentObject var store: AppStore

    var region1: Binding<PageRegion>
    var region2: Binding<PageRegion>

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                TextField("\(region1.regionName.wrappedValue)", text: region1.textResult)
                TextField("\(region2.regionName.wrappedValue)", text: region2.textResult)
            }
            Spacer()
            if !region1.textResult.wrappedValue.isEmpty &&
                region1.textResult.wrappedValue == region2.textResult.wrappedValue {
                Image(systemName: "checkmark.seal.fill")
                    .font(.body)
                    .foregroundColor(.green)
            } else {
                Image(systemName: "xmark.seal.fill")
                    .font(.body)
                    .foregroundColor(.red)
            }
        }
    }
}
