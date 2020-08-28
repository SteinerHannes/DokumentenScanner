//
//  StudentValidateView.swift
//  DokumentenScanner
//
//  Created by Hannes Steiner on 24.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

//swiftlint:disable multiple_closures_with_trailing_closure
struct StudentValidateView: View {

    @EnvironmentObject var store: AppStore

    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>

    @Binding var template: Template

    @Binding var validateList: [(student: ExamStudentDTO, probability: Double)]?

    @State private var student: ExamStudentDTO?

    @State private var showAlert: Bool = false

    var points: String {
        let page = self.store.states.ocrState.result.first!
        let result = page!.first(where: { (region) -> Bool in
            region.datatype == .point
        })
        return result?.textResult ?? "Fehler"
    }

    var grade: String {
        let page = self.store.states.ocrState.result.first!
        let result = page!.first(where: { (region) -> Bool in
            region.datatype == .mark
        })
        return result?.textResult ?? "Fehler"
    }

    var body: some View {
        NavigationView {
            Form {
                if self.validateList == nil {
                    Text("Fehler")
                } else if self.validateList!.isEmpty {
                    Text("Keine Einträge")
                } else {
                    Section {
                        Button(action: {
                            self.showAlert = true
                        }) {
                            Text("Ergebnisse abschicken")
                        }.disabled(self.student == nil)
                    }
                    Section(header: Text("Studenten die noch keine Note haben:")) {
                        ForEach(validateList!, id: \.student.id ) { studentAndP in
                            Button(action: {
                                self.student = studentAndP.student
                            }) {
                                StudentProbabilityRow(
                                    selectedStudent: self.$student,
                                    studentAndP: studentAndP
                                )
                            }
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .navigationBarTitle(Text("Auswahl"), displayMode: .inline)
            .onAppear {
                guard let list = self.validateList else {
                    return
                }
                self.student = list.first?.student
            }
            .alert(isPresented: self.$showAlert) { () -> Alert in
                Alert(
                    //swiftlint:disable line_length
                    title: Text("Ergebnisse für \(self.student!.firstname) \(self.student!.lastname) abschicken?"),
                    //swiftlint:enable line_length
                    message: Text("""
                                    Ergebnisse:
                                    Name: \(self.student!.firstname) \(self.student!.lastname)
                                    Matrikelnummer: \(self.student!.id)
                                    Punkte: \(self.points)
                                    Note: \(self.grade)
                                    """),
                    primaryButton: .default(Text("Abschicken"), action: {
                        let studentId = self.student!.id
                        guard let grade = Double(self.grade.replacingOccurrences(of: ",", with: ".")) else {
                            sendNotification(titel: "Keine gültige Note:", description: self.grade)
                            return
                        }
                        guard let points = Int(self.points) else {
                            sendNotification(titel: "Keine gültigen Punkte:", description: self.points)
                            return
                        }
                        let status: Status
                        if grade == 5.0 {
                            status = .NichtBestanden
                        } else {
                            status = .Bestanden
                        }
                        let result = ExamResultDTO(
                            studentId: studentId,
                            grade: grade,
                            points: points,
                            status: status
                        )
                        let index = self.template.studentList!.firstIndex { (student) -> Bool in
                            student.id == result.studentId
                        }
                        let student = self.template.studentList![index!]
                        self.template.studentList![index!] = ExamStudentDTO(
                            id: student.id,
                            firstname: student.firstname,
                            lastname: student.lastname,
                            birthday: student.birthday,
                            seminarGroup: student.seminarGroup,
                            grade: grade,
                            points: points,
                            status: status
                        )
                        self.store.send(.service(
                            action: .editStudentExam(
                                examId: self.template.examId,
                                result: result
                                )
                            )
                        )
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.store.send(.service(action: .getStudentList(examId: self.template.examId)))
                            print("Get LISTE")
                        }
                        self.presentation.wrappedValue.dismiss()
                    }),
                    secondaryButton: .cancel())
            }
        }
    }
}

struct StudentProbabilityRow: View {
    @Binding var selectedStudent: ExamStudentDTO?

    let studentAndP : (student: ExamStudentDTO, probability: Double)

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(studentAndP.student.firstname) +
            Text(" ") +
            Text(studentAndP.student.lastname)
            Spacer()
            Text("\(Int(studentAndP.probability * 100)) %")
            if self.selectedStudent == studentAndP.student {
                Image(systemName: "checkmark")
                    .font(Font.bold(.body)())
                    .foregroundColor(.accentColor)
            }
        }.foregroundColor(.label)
    }
}

struct StudentValidateView_Previews: PreviewProvider {
    static var previews: some View {
        StudentValidateView(
            template: .constant(AppStoreMock.realTemplate()),
            validateList: .constant(AppStoreMock.probablilityList())
        )
        .environmentObject(AppStoreMock.getAppStore())
    }
}
