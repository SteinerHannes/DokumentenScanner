//
//  Routing.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 31.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation

/// The actions to mange routing
enum RoutingAction {
    /// Shows the PageSelectView
    case showPageSelectView
    /// Shows the ContentView
    case showContentView
    /// Triggers the ScannerView
    case turnOnCamera
    /// Dismisses the ScannerView
    case turnOffCamera
}

/// The routing variables
struct RoutingState {
    var isPageSelectViewPresented: Bool = false
    var isCameraPresented: Bool = false
}

/// The routing reducer for the funtionality of the routing actions
func routingReducer(state: inout RoutingState, action: RoutingAction) {
    switch action {
        case .showPageSelectView:
            state.isPageSelectViewPresented = true
        
        case .showContentView:
            state.isPageSelectViewPresented = false
        
        case .turnOnCamera:
            state.isCameraPresented = true
        
        case .turnOffCamera:
            state.isCameraPresented = false
    }
}
