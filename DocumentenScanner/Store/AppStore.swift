//
//  Store.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 15.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

//swiftlint:disable switch_case_alignment
import Foundation
import Combine
import VisionKit

enum RoutingAction {
    case showNewTemplateView
    case showTemplateDetailView
    case showPageSelectView
    case showContentView
}

struct RoutingState {
    var isNewTemplateViewPresented: Bool = false
    var isTemplateDetailViewPresented:Bool = false
    var isPageSelectViewPresented: Bool = false
}

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

enum NewTemplateAction {
    case createNewTemplate(name: String, info: String)
    case addPagesToNewTemplate(pages: [Page])
    case clearNewTemplate
    case clearState
    case setImageAndPageNumber(number: Int)
    case removeAttribute(id: String)
    case setAttribute(name: String, datatype: Int)
    case addAttributeToPage(height: CGFloat, width: CGFloat, rectState: CGSize)
    case clearCurrentAttribute
}

struct NewTemplateState {
    var newTemplate: Template?
    var image: UIImage?
    var currentAttribut: ImageRegion?
    var currentPage: Int?
    var maxHeight: CGFloat = 140
}

func newTemplateReducer(state: inout NewTemplateState, action: NewTemplateAction) {
    switch action {
        case let .createNewTemplate(name: name, info: info):
            var template = Template()
            template.name = name
            template.info = info
            state.newTemplate = template
        case let .addPagesToNewTemplate(pages: pages):
            state.newTemplate!.pages = pages
        case .clearNewTemplate:
            state.newTemplate = nil
        case .clearState:
            state.currentAttribut = nil
            state.currentPage = nil
            state.image = nil
            state.maxHeight = 140
            state.newTemplate = nil
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
    }
}

struct AppEnviorment {
    var service = TemplateService()
}

/// The actions of the app state
enum AppAction {
    case routing(action: RoutingAction)
    case newTemplate(action: NewTemplateAction)
    case clearCurrentTemplate
    case setCurrentTemplate(id: String)
    case addNewTemplate(template: Template)
}

/// The new app state
struct AppStates {
    var routes: RoutingState
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
