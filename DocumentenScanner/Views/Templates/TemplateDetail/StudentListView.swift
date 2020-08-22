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

    var body: some View {
        Form {
            if template.studentList == nil {
                Text("Wird heruntergeladen")
            } else if template.studentList!.isEmpty {
                Text("Keine Studenten eingetragen")
            } else {
                ForEach(template.studentList!.filter({ (student) -> Bool in
                    guard let filter = self.filter else {
                        return true
                    }
                    return student.status == filter
                }) ,id: \.id) { student in
                    StudentRow(student: student)
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
    }

    private func trailingItem() -> some View {
        return
            HStack(alignment: .center, spacing: 20) {
                Button(action: {
                    self.showActionSheet = true
                }) {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                        .font(.body)
                    Text("Filter")
                }
                StartStopButton().environmentObject(self.store)
        }
    }
}

struct StudentRow: View {
    let student: ExamStudentDTO

    var body: some View {
        HStack(alignment: .center, spacing: 3) {
            Text(self.student.lastname)
            Text(self.student.firstname)
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
