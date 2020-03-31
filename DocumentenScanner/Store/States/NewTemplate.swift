//
//  NewTemplate.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 31.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import SwiftUI
//swiftlint:disable switch_case_alignment cyclomatic_complexity

/// The actions for managing the new template
enum NewTemplateAction {
    /// Create a new template -> var newTemplate
    /// - parameter name: The name of the template
    /// - parameter info: An info text, about the template
    case createNewTemplate(name: String, info: String)
    /// Add pages to var newTemplate.pages
    /// - parameter pages: A List of pages of the template
    case addPagesToNewTemplate(pages: [Page])
    /// Make all variables nil and initilaize the LinkState
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
    /// The reducer function of the link state
    /// for the functionality of the link actions
    /// - parameter action: A LinkAction for mutating the link state
    case links(action: LinkAction)
    /// Adds combines the variables from link state to create a link
    /// and to add it to the link list of the template
    case addLinkToNewTemplate
    /// Delets a link from the link list of the new template
    case deletLinkFromNewTemplate(linkID: String)
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
    /// The state for handling the link variables
    var linkState: LinkState

    init() {
        self.linkState = LinkState()
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
            state.linkState = LinkState()

        case let .setImageAndPageNumber(number: number):
            state.image = state.newTemplate!.pages[number].image
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

        case let .links(action: action):
            linkReducer(state: &state.linkState, action: action)

        case .addLinkToNewTemplate:
            let regionIDs = state.linkState.firstSelections! + state.linkState.secondSelections!

            let link = Link(linktype: state.linkState.currentType!, regionIDs: regionIDs)
            state.newTemplate!.links.append(link)

        case let .deletLinkFromNewTemplate(linkID: id):
            if let index = state.newTemplate!.links.firstIndex(where: { (link) -> Bool in
                link.id == id
            }) {
                state.newTemplate!.links.remove(at: index)
        }
    }
}
