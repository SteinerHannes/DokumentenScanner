//
//  StudentListView.swift
//  DokumentenScanner
//
//  Created by Hannes Steiner on 22.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

//swiftlint:disable multiple_closures_with_trailing_closure
struct StudentListView: View {
    @EnvironmentObject var store: AppStore

    let template: Template

    @State var filter: Status?
    @State var showActionSheet: Bool = false
    @State var showGrade: Bool = true

    private var buttonList: [ActionSheet.Button] {
        var list = Status.allCases.map { status -> ActionSheet.Button in
            .default(Text("\(status.rawValue)")) {
                self.filter = status
            }
        }
        list.append(.default(Text("Zurücksetzen"), action: {
            self.filter = nil
        }))
        list.append(.cancel())
        return list
    }

    var controlledStudents: String {
        guard let list = template.studentList else {
            return "?"
        }
        let temp = list.filter { (student) -> Bool in
            if student.grade == nil {
                return false
            } else {
                return true
            }
        }
        return "\(temp.count)"
    }

    var allStudents: String {
        guard let students = template.studentList?.count else {
            return "?"
        }
        return "\(students)"
    }

    var illStudents: Int {
        guard let students = template.studentList else {
            return 0
        }
        let temp = students.filter { (student) -> Bool in
            return student.status == .Krank
        }
        return temp.count
    }

    var filterText: String {
        return "Gefiltert nach: \(self.filter?.rawValue ?? "-")"
    }

    var body: some View {
        Form {
            if template.studentList == nil {
                Text("Wird heruntergeladen")
            } else if template.studentList!.isEmpty {
                Text("Keine Studenten eingetragen")
            } else {
                Section(header: Text("Info:")) {
                    Text("\(controlledStudents) von \(allStudents) Klausuren bewertet")
                    Text("Kranke Studenten: \(illStudents)")
                }
                Section(
                    header:
                        HStack(alignment: .center, spacing: 0, content: {
                            Text(filterText)
                            Spacer()
                            Button(action: {
                                self.showGrade.toggle()
                            }) {
                                if self.showGrade {
                                    Text("Status anzeigen")
                                } else {
                                    Text(" Noten anzeigen")
                                }
                            }
                        }
                    )
                ) {
                    ForEach(template.studentList!.filter({ (student) -> Bool in
                        guard let filter = self.filter else {
                            return true
                        }
                        return student.status == filter
                    }) ,id: \.id) { student in
                        StudentRow(showGrade: self.$showGrade, student: student)
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarItems(trailing: self.trailingItem())
        .actionSheet(isPresented: self.$showActionSheet) { () -> ActionSheet in
            ActionSheet(
                title: Text("Studenten filtern nach:"),
                message: nil,
                buttons: buttonList
            )
        }
        .navigationBarTitle(Text("Eingetragene Studenten"), displayMode: .inline)
    }

    private func trailingItem() -> some View {
        return
            HStack(alignment: .center, spacing: 20) {
                Button(action: {
                    self.showActionSheet = true
                }) {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                        .font(.body)
                }
                StartStopButton().environmentObject(self.store)
        }
    }
}

struct StudentRow: View {
    @Binding var showGrade: Bool

    let student: ExamStudentDTO

    var body: some View {
        HStack(alignment: .center, spacing: 3) {
            Text(self.student.firstname)
            Text(self.student.lastname)
            Spacer()
            if showGrade {
                Text(self.student.grade == nil ?
                    "Keine Note" :
                    String.init(format: "%.01f", arguments: [self.student.grade!])
                )
                .foregroundColor( self.student.status == .Bestanden ? .green :
                    (self.student.status == .Täuschung ? .red :
                        (self.student.status == .NichtBestanden ? .red : .label))
                )
            } else {
                Text(self.student.status.rawValue)
                    .foregroundColor( self.student.status == .Bestanden ? .green :
                        (self.student.status == .Täuschung ? .red :
                            (self.student.status == .NichtBestanden ? .red : .label))
                    )
            }
        }
    }
}

struct StudentListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StudentListView(template: AppStoreMock.realTemplate())
                .environmentObject(AppStoreMock.getAppStore())
        }
    }
}
