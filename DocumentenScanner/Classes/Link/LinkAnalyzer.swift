//
//  LinkAnalyzer.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 19.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation

final class LinkAnalyzer {
    private let results: [String: String] //self.links,
    private let links: [Link] //self.store.states.currentTemplate!.links

    private var errors: [String] = []

    init(results: [String: String], links: [Link]) {
        self.links = links
        self.results = results
    }

    /// A dispatch queue (thread) for multithreading the text recognition
    private let queue = DispatchQueue(label: "com.dokumentenscanner.analyze",
                                      qos: .background, attributes: [], autoreleaseFrequency: .workItem)

    func analyze(withCompletionHandler completionHandler: @escaping ([String])
        -> Void) {
        queue.async {
            for link in self.links {
                switch link.linktype {
                    case .compare:
                        guard let error = self.compare(link: link) else {
                            continue
                        }
                        self.errors.append(error)
                    case .sum:
                        break
                }
            }

            DispatchQueue.main.async {
                completionHandler(self.errors)
            }
        }
    }

    private func compare(link: Link) -> String? {
        let result1: String = results[link.regionIDs[0]] ?? "Fehler 1"
        let result2: String = results[link.regionIDs[1]] ?? "Fehler 2"
        if result1 != result2 {
            return "\(results[link.regionIDs[0]] ?? "Fehler 1") ist ungleich \(results[link.regionIDs[1]] ?? "Fehler 2")"
        }
        return nil
    }
}
