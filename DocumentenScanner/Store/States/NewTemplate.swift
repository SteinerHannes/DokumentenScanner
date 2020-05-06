//
//  NewTemplate.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 31.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import SwiftUI
//swiftlint:disable switch_case_alignment cyclomatic_complexity function_body_length

/// The actions for managing the new template
enum NewTemplateAction {
    /// Create a new template -> var newTemplate
    /// - parameter name: The name of the template
    /// - parameter info: An info text, about the template
    case createNewTemplate(name: String, info: String)
    /// Add pages to var newTemplate.pages
    /// - parameter pages: A List of pages of the template
    case addPagesToNewTemplate(pages: [Page])
    /// Make all variables nil and initilaize the ControlState
    case clearState
    /// Set var currentPage to the page number you want
    /// and therefor it sets var image too the image from this page
    /// - parameter number: The page number you want
    case setImageAndPageNumber(number: Int)
    /// Removes the Attribute
    /// - parameter id: The unique identifier of the attribute
    case removeAttribute(id: String)
    /// Sets var currentAttribute
    /// - parameter name: The name of the attribute
    /// - parameter datatype: The ResultDatatype of the attribute
    case setAttribute(name: String, datatype: ResultDatatype)
    /// Set the height, width and rectState of the Attribute, adds it to the current page and clears it after
    /// - parameter height: The height of the region
    /// - parameter width: The width of the region
    /// - parameter rectState: The start point of the region
    case setRegionAndAddAttributeToPage(height: CGFloat, width: CGFloat, rectState: CGSize)
    /// Sets the current attribute to nil
    case clearCurrentAttribute
    /// The reducer function of the control state
    /// for the functionality of the control actions
    /// - parameter action: A ControlAction for mutating the control state
    case controls(action: ControlAction)
    /// Adds combines the variables from control state to create a control mechanism
    /// and to add it to the control mechanisms list of the template
    case addControlMechanismToNewTemplate
    /// Delets a control mechanism from the control mechanisms list of the new template
    case deletControlMechanismFromNewTemplate(mechanismID: String)
    case setTemplate(template: Template)
}

/// The variables required for handling the new template
struct NewTemplateState {
    /// The new template you create and will save later
    var newTemplate: Template?
    /// The image for the SelectRegionView and other detail views
    var image: UIImage?
    /// The page number for the views after the PageSelectView and following views
    var currentPage: Int?
    /// The current attribute you create in the NewAttributeView and others
    var currentAttribut: ImageRegion?
    /// The state for handling the control machanism variables
    var controlState: ControlState

    init() {
        self.controlState = ControlState()
    }
}

/// The reducer of the new template
/// for the functionality of the template actions
func newTemplateReducer(state: inout NewTemplateState, action: NewTemplateAction) {
    switch action {
        case let .createNewTemplate(name: name, info: info):
            var template = Template()
            template.name = name
            template.info = info
            state.newTemplate = template

        case let .addPagesToNewTemplate(pages: pages):
            state.newTemplate!.pages = pages

        case .clearState:
            state.currentAttribut = nil
            state.currentPage = nil
            state.image = nil
            state.newTemplate = nil
            state.controlState = ControlState()

        case let .setImageAndPageNumber(number: number):
            state.image = state.newTemplate!.pages[number]._image
            state.currentPage = number

        case let .removeAttribute(id: id):
            if let index = state.newTemplate!.pages[state.currentPage!].regions.firstIndex(where: {
                $0.id == id
            }) {
                state.newTemplate!.pages[state.currentPage!].regions.remove(at: index)
        }

        case let .setAttribute(name: name, datatype: type):
            state.currentAttribut = ImageRegion(name: name, datatype: type)

        case .clearCurrentAttribute:
            state.currentAttribut = nil

        case let .setRegionAndAddAttributeToPage(height: height, width: width, rectState: rectState):
            state.currentAttribut!.height = height
            state.currentAttribut!.width = width
            state.currentAttribut!.rectState = rectState
            state.newTemplate!.pages[state.currentPage!].regions.append(state.currentAttribut!)

        case let .controls(action: action):
            controlReducer(state: &state.controlState, action: action)

        case .addControlMechanismToNewTemplate:
            let regionIDs = state.controlState.firstSelections! + state.controlState.secondSelections!

            let machanism = ControlMechanism(controltype: state.controlState.currentType!,
                                             regionIDs: regionIDs)
            state.newTemplate!.controlMechanisms.append(machanism)

        case let .deletControlMechanismFromNewTemplate(mechanismID: id):
            if let index = state.newTemplate!.controlMechanisms.firstIndex(where: { (control) -> Bool in
                control.id == id
            }) {
                state.newTemplate!.controlMechanisms.remove(at: index)
        }
        case let .setTemplate(template: template):
            state.newTemplate = template
    }
}
