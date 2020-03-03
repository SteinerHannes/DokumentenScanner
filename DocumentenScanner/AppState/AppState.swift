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
    @Published var isCreateTemplateViewPresented: Bool = false
    @Published var showRoot: Bool = false
    @Published var image: UIImage?
    @Published var currentAttribut: ImageAttribute?
    @Published var attributList: [ImageAttribute] = []
    @Published var maxHeight: CGFloat = 140
    
    func reset() {
        self.attributList = []
        self.image = nil
        self.currentAttribut = nil
        self.maxHeight = 140
        self.isCreateTemplateViewPresented = false
        self.showRoot = false
        cleanCurrentImageTemplate()
    }
    
    func cleanCurrentImageTemplate() {
        self.currentImageTemplate = nil
    }
    
    @Published var isNewTemplateViewPresented: Bool = false
    @Published var templates: [ImageTemplate] = []
//        [ImageTemplate(attributeList: [ImageAttribute(name: "Test", rectState: CGSize(width: 51.83290452120362, height: 287.44967173569563), width: 259.4739028991718, height: 36.7910673501724, datatype: 0)], image: UIImage(imageLiteralResourceName: "test"), name: "Test-Bild", info: "Echtes Test-Bild")]
    @Published var currentImageTemplate: ImageTemplate?
    
    func setCurrentImageTemplate(for id: String){
        self.currentImageTemplate = self.templates.first(where: { template -> Bool in
            template.id == id
        })
    }
    
    @Published var isTemplateDetailViewPresented:Bool = false
}
