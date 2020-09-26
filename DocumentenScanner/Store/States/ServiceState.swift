//
//  ServiceState.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 02.04.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

//swiftlint:disable cyclomatic_complexity function_body_length
import Foundation
import Combine
import SwiftUI

struct ServiceState {
    var templateId: Int?
    var pageId: Int?
    var pageNumber: Int?
    var attributeNumber: Int?
}

enum ServiceAction {
    /// Sends the template to the server
    case createTemplate
    /// Handels the result from the create template function in template service
    case createTeamplateResult(result: Result<TemplateDTO, TemplateServiceError>)
    /// Sends the template to the server
    case createPage(templateId: Int, number: Int, imagePath: String)
    /// Handels the result from the create page function in template service
    case createPageResult(result: Result<PageDTO, TemplateServiceError>)
    /// Sends the attribute to the server
    case createAttribute(name: String, x: Int, y: Int, width: Int, height: Int, dataType: String, pageId: Int)
    /// Handels the result from the create attribute function in template service
    case createAttributeResult(result: Result<AttributeDTO, TemplateServiceError>)
    /// Upload an image
    case uploadImage(image: UIImage)
    /// Handels the result from uploading an image and starting the createPage-Action
    case uploadImageResult(result: Result<String, TemplateServiceError>)
    /// Reset the ServiceState
    case resetState
    /// Download all Templates
    case getTemplateList
    /// Handels the result from the download
    case getTemplateListResult(result: Result<[Template], TemplateServiceError>)
    /// Delete Template with the given id
    case deleteTemplate(id: String)
    /// Handles the delete-Result
    case deleteTemplateResult(result: Result<String, TemplateServiceError>)
    /// Download all stundets and their status for the examId (examId is part of the template, has to be manually put in the data base )
    case getStudentList(examId: Int)
    /// Handels the result from the getStudentList-Action
    case getStudentListResult(result: Result<(list: [ExamStudentDTO]?, id: Int), ExamServiceError>)
    /// Adds and/or edits the exam result of one student
    case editStudentExam(examId: Int, result: ExamResultDTO)
    /// Handels the result from editStudentExam-Action
    case editStudentExamResult(result: Result<String, ExamServiceError>)
}

func serviceReducer(states: inout AppStates, action: ServiceAction, enviorment: AppEnviorment)
    -> AnyPublisher<AppAction, Never>? {
        switch action {
            case let .getTemplateListResult(result: result):
                switch result {
                    case let .success(list):
//                        for template in list where !states.teamplates.contains(where: { (item) -> Bool in
//                            item.id == template.id
//                        }) {
//                            states.teamplates.append(template)
//                        }
                        states.teamplates = list
                    case let .failure(error):
                        sendNotification(titel: "Fehler",
                                         description: error.localizedDescription)
                        print("get TemplateList:", error)
            }

            case .getTemplateList:
                return enviorment.template.getTemplateList()

            case .createTemplate:
                let name = states.newTemplateState.newTemplate!.name
                let description = states.newTemplateState.newTemplate!.info
                let controlMechanisms = states.newTemplateState.newTemplate!.controlMechanisms
                return enviorment.template.createTemplate(name: name,
                                                          description: description,
                                                          machanisms: controlMechanisms)

            case let .createTeamplateResult(result: result):
                switch result {
                    case let .success(template):
                        states.serviceState.templateId = template.id
                        print("erstelltes Template hat die id:", template.id)
                        states.serviceState.pageNumber = 0
                        states.serviceState.attributeNumber = 0
                        return
                            Just(.service(action:
                                .uploadImage(image: states.newTemplateState.newTemplate!.pages[0]._image!)))
                            .eraseToAnyPublisher()
                    case let .failure(error):
                        sendNotification(titel: "Fehler",
                                         description: error.localizedDescription)
                        print("fehler", error)
                }

            case let .createPage(templateId: id, number: number, imagePath: imagePath):
                return enviorment.template.createPage(id: id, number: number, imagePath: imagePath)

            case .createPageResult(result: let result):
                switch result {
                    case let .success(page):
                        states.serviceState.pageId = page.id
                        let pageNum = states.serviceState.pageNumber!
                        let attNum = states.serviceState.attributeNumber!
                        let template = states.newTemplateState.newTemplate!
                        if pageNum < template.pages.count {
                            if attNum < template.pages[pageNum].regions.count {
                                let attribute = template.pages[pageNum].regions[attNum]
                                states.serviceState.attributeNumber! += 1
                                return Just<AppAction>(
                                    .service(action:
                                        .createAttribute(name: attribute.name,
                                                         x: Int(attribute.rectState.width),
                                                         y: Int(attribute.rectState.height),
                                                         width: Int(attribute.width),
                                                         height: Int(attribute.height),
                                                         dataType: attribute.datatype.getNameType(),
                                                         pageId: page.id)))
                                    .eraseToAnyPublisher()
                            }
                            if pageNum < template.pages.count-1 {
                                states.serviceState.pageNumber! += 1
                                return Just<AppAction>(
                                    .service(action:
                                        .uploadImage(image: template.pages[pageNum+1]._image!))
                                ).eraseToAnyPublisher()
                            }
                        }
                        print("Neu laden")
                        return Just<AppAction>(
                            .service(action: .getTemplateList)
                        ).eraseToAnyPublisher()
                    case let .failure(error):
                        sendNotification(titel: "Fehler",
                                         description: error.localizedDescription)
                        print("page fehler:", error)
                }

            case let .createAttribute(name: name, x: x, y: y, width: width,
                                      height: height, dataType: dataType, pageId: pageId):
                return enviorment.template.createAttribute(name: name, x: x, y: y, width: width,
                                                    height: height, dataType: dataType, pageId: pageId)

            case let .createAttributeResult(result: result):
                switch result {
                    case let .success(attribute):
                        let pageNum = states.serviceState.pageNumber!
                        let attNum = states.serviceState.attributeNumber!
                        let template = states.newTemplateState.newTemplate!
                        if attNum < template.pages[pageNum].regions.count {
                            let nextAttribute = template.pages[pageNum].regions[attNum]
                            states.serviceState.attributeNumber! += 1
                            print("attribute erstellt:", attribute.name)
                            return Just<AppAction>(
                                .service(action:
                                    .createAttribute(name: nextAttribute.name,
                                                     x: Int(nextAttribute.rectState.width),
                                                     y: Int(nextAttribute.rectState.height),
                                                     width: Int(nextAttribute.width),
                                                     height: Int(nextAttribute.height),
                                                     dataType: nextAttribute.datatype.getNameType(),
                                                     pageId: states.serviceState.pageId!)))
                                .eraseToAnyPublisher()
                        }
                        states.serviceState.attributeNumber = 0
                        if pageNum < template.pages.count-1 {
                            states.serviceState.pageNumber! += 1
                            return Just<AppAction>(
                                .service(action:
                                    .uploadImage(image: template.pages[pageNum+1]._image!))
                            ).eraseToAnyPublisher()
                        }
                        print("Neu laden")
                        return Just<AppAction>(
                            .service(action: .getTemplateList)
                        ).eraseToAnyPublisher()
                    case let .failure(error):
                        sendNotification(titel: "Fehler",
                                         description: error.localizedDescription)
                        print("attribute fehler:", error)
                }

            case let .uploadImage(image: image):
                return enviorment.template.uploadImage(image: image)

            case let .uploadImageResult(result: result):
                switch result {
                    case let .success(url):
                        return
                            Just(.service(action:
                                .createPage(templateId: states.serviceState.templateId!,
                                            number: states.serviceState.pageNumber!,
                                            imagePath: url)))
                                .eraseToAnyPublisher()
                    case let .failure(error):
                        sendNotification(titel: "Fehler",
                                         description: error.localizedDescription)
                        print("upload fehler: ", error )
            }
            case .resetState:
                states.serviceState = ServiceState()

            case let .deleteTemplate(id: id):
                return enviorment.template.deleteTemplate(id: id)

            case let .deleteTemplateResult(result: result):
                switch result {
                    case let .success(text):
                        print(text)
                        return Just<AppAction>(
                            .service(action: .getTemplateList)
                        ).eraseToAnyPublisher()
                    case let .failure(error):
                        sendNotification(titel: "Fehler",
                                         description: error.localizedDescription)
                        print("delete", error)
                }
            case let .getStudentList(examId: id):
                return enviorment.exam.getStudentList(examId: id)

            case let .getStudentListResult(result: result):
                switch result {
                    case let .success(listAndId):
                        return Just<AppAction>(
                            .setStudentList(result: listAndId)
                        ).eraseToAnyPublisher()
                    case let .failure(error):
                        sendNotification(titel: "Fehler",
                                         description: error.localizedDescription)
                        print("getStudentListResult", error)
            }

            case let .editStudentExam(examId: id, result: result):
                return enviorment.exam.editStudentResult(examId: id, result: result)
            case let .editStudentExamResult(result: result):
                switch result {
                    case .success:
                        print("editStudentExamResult FINISHED")
                    case let .failure(error):
                        sendNotification(titel: "Fehler",
                                         description: error.localizedDescription)
                        print("editStudentExamResult", error)
            }

        }
        return Empty().eraseToAnyPublisher()
}
