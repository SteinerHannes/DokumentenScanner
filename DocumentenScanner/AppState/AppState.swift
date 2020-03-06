//
//  AppState.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 26.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import SwiftUI
import VisionKit

final class AppState: ObservableObject {
    @Published var isPageSelectViewPresented: Bool = false
    @Published var showRoot: Bool = false
    @Published var image: UIImage?
    @Published var currentAttribut: ImageRegion?
    @Published var currentPage: Int?
    @Published var maxHeight: CGFloat = 140

    func reset() {
        self.image = nil
        self.currentAttribut = nil
        self.maxHeight = 140
        self.isPageSelectViewPresented = false
        self.showRoot = false
        self.currentPage = nil
        cleanCurrentImageTemplate()
    }

    func cleanCurrentImageTemplate() {
        self.currentTemplate = nil
    }

    @Published var isNewTemplateViewPresented: Bool = false
    @Published var templates: [Template] = []
    @Published var currentTemplate: Template?

    func setCurrentTemplate(for id: String) {
        self.currentTemplate = self.templates.first(where: { template -> Bool in
            template.id == id
        })
    }

    @Published var isTemplateDetailViewPresented:Bool = false
}
