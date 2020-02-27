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

final class AppState : ObservableObject {
    @Published var isCreateTemplateViewPresented:Bool = false
    @Published var showRoot:Bool = false
    @Published var image:UIImage? = nil
    @Published var currentAttribut:ImageAttribute? = nil
    @Published var attributList:[ImageAttribute] = []
    @Published var maxHeight:CGFloat = 140
    
    func reset(){
        self.attributList = []
        self.image = nil
        self.currentAttribut = nil
        self.maxHeight = 140
        self.isCreateTemplateViewPresented = false
        self.showRoot = false
    }
    
    @Published var templates:[ImageTemplate] = []
    
}
