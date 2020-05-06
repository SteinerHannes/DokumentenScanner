//
//  Controls.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 31.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation

/// The actions for managing the variables in ControlState
enum ControlAction {
    /// Set the control type for the new control mechanism
    /// - parameter type: The control type of the new control mechanism
    case setControlType(type: ControlType)
    /// Set the first selection of regions to later combine them to a new control mechanism
    /// - parameter selections: A list of region ids
    case setFirstSelections(selections: [String])
    /// Set the second selection of regions to later combine them to a new control mechanism
    /// - parameter selections: A list of region ids
    case setSecondSelections(selections: [String])
    /// Sets all variables in the control state to nil
    case clearControlMechanism
}

/// The state for a new control created in the AddControllMachanismView and RegionsListView
struct ControlState {
    /// The type of the control
    var currentType: ControlType? = .compare
    /// The first selection of region ids
    var firstSelections: [String]?
    /// The second selection of region ids
    var secondSelections: [String]?
}

/// The reducer the handle the functionality of the control state actions
func controlReducer(state: inout ControlState, action: ControlAction) {
    switch action {
        case let .setControlType(type: type):
            state.currentType = type

        case let .setFirstSelections(selections: regions):
            state.firstSelections = regions

        case let .setSecondSelections(selections: regions):
            state.secondSelections = regions

        case .clearControlMechanism:
            state.currentType = nil
            state.firstSelections = nil
            state.secondSelections = nil
    }
}
