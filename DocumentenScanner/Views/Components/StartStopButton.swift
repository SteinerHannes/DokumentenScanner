//
//  StartStopButton.swift
//  DokumentenScanner
//
//  Created by Hannes Steiner on 29.07.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import SwiftUI

struct StartStopButton: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        Button(action: {
            if self.store.states.logState.isLoggin {
                self.store.send(.log(action: .stop))
            } else {
                self.store.send(.log(action: .start))
            }
        }, label: {
            if self.store.states.logState.isLoggin {
                Image(systemName: "pause.fill")
            } else {
                Image(systemName: "play.fill")
            }
        })
    }
}
