//
//  Links.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 31.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation

/// The actions for managing the variables in LinkState
enum LinkAction {
    /// Set the link type for the new link
    /// - parameter type: The link type of the new link
    case setLinkType(type: LinkType)
    /// Set the first sekection of regions to later combine them to a new link
    /// - parameter selections: A list of region ids
    case setFirstSelections(selections: [String])
    /// Set the second sekection of regions to later combine them to a new link
    /// - parameter selections: A list of region ids
    case setSecondSelections(selections: [String])
    /// Sets all variables in the link state to nil
    case clearLink
}

/// The state for a new link created in the AddLinkView and RegionsListView
struct LinkState {
    /// The type of the link
    var currentType: LinkType? = .compare
    /// The first selection of region ids
    var firstSelections: [String]?
    /// The second selection of region ids
    var secondSelections: [String]?
}

/// The reducer the handle the functionality of the link state actions
func linkReducer(state: inout LinkState, action: LinkAction) {
    switch action {
        case let .setLinkType(type: type):
            state.currentType = type
        
        case let .setFirstSelections(selections: links):
            state.firstSelections = links
        
        case let .setSecondSelections(selections: links):
            state.secondSelections = links
        
        case .clearLink:
            state.currentType = nil
            state.firstSelections = nil
            state.secondSelections = nil
    }
}
