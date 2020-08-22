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

    var controlledStudents: Int {
        return 3
    }

    var allStudents: Int {
        return 12
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text("\(controlledStudents) von \(allStudents) Klausuren kontrolliert")
            Spacer()
            NavigationLink(destination: StudentListView()) {
                HStack(alignment: .center, spacing: 5) {
                    Text("Überprüfen")
                    Image(systemName: "chevron.right")
                }
            }
        }
        .padding(.horizontal)
        .onAppear {
            #warning("hier dann StudentenListe downloaden")
        }
    }
}

struct DocumentExam_Previews: PreviewProvider {
    static var previews: some View {
        DocumentExam(template: AppStoreMock.getTemplate())
            .environmentObject(AppStoreMock.getAppStore())
    }
}
