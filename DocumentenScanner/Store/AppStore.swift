//
//  Store.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 15.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

//swiftlint:disable switch_case_alignment cyclomatic_complexity
import Foundation
import Combine
import VisionKit

/// The actions to mange routing
enum RoutingAction {
    case showNewTemplateView
    case showTemplateDetailView
    case showPageSelectView
    case showContentView
}

/// The routing variables
struct RoutingState {
    var isNewTemplateViewPresented: Bool = false
    var isTemplateDetailViewPresented: Bool = false
    var isPageSelectViewPresented: Bool = false
}

/// The routing reducer for the funtionality of the routing actions
func routingReducer(state: inout RoutingState, acction: RoutingAction) {
    switch acction {
        case .showNewTemplateView:
            state.isPageSelectViewPresented = false
            state.isTemplateDetailViewPresented = false
            state.isNewTemplateViewPresented = true
        case .showPageSelectView:
            state.isNewTemplateViewPresented = false
            state.isTemplateDetailViewPresented = false
            state.isPageSelectViewPresented = true
        case .showTemplateDetailView:
            state.isNewTemplateViewPresented = false
            state.isPageSelectViewPresented = false
            state.isTemplateDetailViewPresented = true
        case .showContentView:
            state.isNewTemplateViewPresented = false
            state.isPageSelectViewPresented = false
            state.isTemplateDetailViewPresented = false
    }
}

/// The actions for managing the new template
enum NewTemplateAction {
    case createNewTemplate(name: String, info: String)
    case addPagesToNewTemplate(pages: [Page])
    case clearState
    case setImageAndPageNumber(number: Int)
    case removeAttribute(id: String)
    case setAttribute(name: String, datatype: ResultDatatype)
    case addAttributeToPage(height: CGFloat, width: CGFloat, rectState: CGSize)
    case clearCurrentAttribute
    case links(action: LinkAction)
    case addLinkToNewTemplate
    case deletLinkFromNewTemplate(linkID: String)
}

/// The variables required for handling the new template
struct NewTemplateState {
    var newTemplate: Template?
    var image: UIImage?
    var currentAttribut: ImageRegion?
    var currentPage: Int?
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

        case let .addAttributeToPage(height: height, width: width, rectState: rectState):
            state.currentAttribut!.height = height
            state.currentAttribut!.width = width
            state.currentAttribut!.rectState = rectState
            state.newTemplate!.pages[state.currentPage!].regions.append(state.currentAttribut!)
            state.currentAttribut = nil

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

enum LinkAction {
    case setLinkType(type: LinkType)
    case setFirstSelections(selections: [String])
    case setSecondSelections(selections: [String])
    case clearLink
}

struct LinkState {
    var links: [Link]?
    var currentType: LinkType? = .compare
    var firstSelections: [String]?
    var secondSelections: [String]?
}

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

/// The enviorment for handling the asyncronously funtions 
struct AppEnviorment {
    var service = TemplateService()
}

/// The actions of the app state
enum AppAction {
    /// The routing reducer function
    case routing(action: RoutingAction)
    /// The reducer function for the new template
    case newTemplate(action: NewTemplateAction)
    case clearCurrentTemplate
    case setCurrentTemplate(id: String)
    case addNewTemplate(template: Template)
}

/// The new app state
struct AppStates {
    /// Variables for routing
    var routes: RoutingState
    /// Variables for the new template
    var newTemplateState: NewTemplateState
    /// The loaded templates
    var teamplates: [Template] = []
    /// The currently inspected template
    var currentTemplate: Template?

    init() {
        self.routes = RoutingState()
        self.newTemplateState = NewTemplateState()
    }
}

/// The reducer the handle the functionality of the app state actions
func appReducer(
    states: inout AppStates,
    action: AppAction,
    enviorment: AppEnviorment
) -> AnyPublisher<AppAction, Never> {
    switch action {
        case let .routing(action: action):
            routingReducer(state: &states.routes, acction: action)
        case let .newTemplate(action: action):
            newTemplateReducer(state: &states.newTemplateState, action: action)
        case let .addNewTemplate(template: template):
            states.teamplates.append(template)
        case let .setCurrentTemplate(id: id):
            states.currentTemplate = states.teamplates.first(where: { template -> Bool in
                template.id == id
            })
        case .clearCurrentTemplate:
            states.currentTemplate = nil
    }
    return Empty().eraseToAnyPublisher()
}

typealias AppStore = Store<AppStates, AppAction, AppEnviorment>
