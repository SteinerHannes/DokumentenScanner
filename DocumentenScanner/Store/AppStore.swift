//
//  AppStore.swift
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
    /// Shows the PageSelectView
    case showPageSelectView
    /// Shows the ContentView
    case showContentView
    case turnOnCamera
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
// swiftlint:enable function_body_length

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

/// The enviorment for handling the asyncronously funtions 
struct AppEnviorment {
    var template = TemplateService()
    var auth = AuthService()
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
    case sendResult(pageNumber: Int, result: [PageRegion])
    case appendResult(at: Int)
    case initResult(array: [[PageRegion]?])
    case clearResult
    case setResult(page: Int, region: Int, text: String)
    case login
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

    var result: [[PageRegion]?] = []

    init() {
        self.routes = RoutingState()
        self.newTemplateState = NewTemplateState()
    }

    init(template: Template) {
        self.routes = RoutingState()
        self.newTemplateState = NewTemplateState()
        self.teamplates.append(template)
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
            routingReducer(state: &states.routes, action: action)
        case let .newTemplate(action: action):
            newTemplateReducer(state: &states.newTemplateState, action: action)
        case let .addNewTemplate(template: template):
            states.teamplates.append(template)
//            for page in template.pages {
//                UIImageWriteToSavedPhotosAlbum(page.image, nil, nil, nil)
//            }
        case let .setCurrentTemplate(id: id):
            states.currentTemplate = states.teamplates.first(where: { template -> Bool in
                template.id == id
            })
        case .clearCurrentTemplate:
            states.currentTemplate = nil
        case let .sendResult(pageNumber: number, result: pageRegions):
            states.result[number] = pageRegions
        case let .appendResult(at: pageNumber):
            states.result[pageNumber] = []
        case let .initResult(array: nilPages):
            states.result = nilPages
        case .clearResult:
            states.result = []
        case let .setResult(page: page, region: region, text: text):
            states.result[page]![region].textResult = text
        case .login:
            enviorment.auth.login()
    }
    return Empty().eraseToAnyPublisher()
}

typealias AppStore = Store<AppStates, AppAction, AppEnviorment>
