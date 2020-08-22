//
//  DocumentExam.swift
//  DokumentenScanner
//
//  Created by Hannes Steiner on 22.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

struct DocumentExam: View {
    @EnvironmentObject var store: AppStore

    let template: Template

    var controlledStudents: String {
        guard let list = template.studentList else {
            return "?"
        }
        let temp = list.filter { (student) -> Bool in
            return student.status == .Bestanden
        }
        return "\(temp.count)"
    }

    var allStudents: String {
        guard let students = template.studentList?.count else {
            return "?"
        }
        return "\(students)"
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text("\(controlledStudents) von \(allStudents) Klausuren kontrolliert")
            Spacer()
            NavigationLink(destination: StudentListView(template: self.template).environmentObject(self.store)) {
                HStack(alignment: .center, spacing: 5) {
                    Text("Überprüfen")
                    Image(systemName: "chevron.right")
                }
            }
        }
        .padding(.horizontal)
        .onAppear {
            if self.template.studentList == nil {
                self.store.send(.service(action: .getStudentList(examId: self.template.examId)))
            }
        }
    }
}

struct DocumentExam_Previews: PreviewProvider {
    static var previews: some View {
        DocumentExam(template: AppStoreMock.getTemplate())
            .environmentObject(AppStoreMock.getAppStore())
    }
}
