//
//  DismissKeyboard.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 27.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import SwiftUI

extension UIApplication {
    /// Triggers the endEditing on an open keybaord
    func endEditing(_ force: Bool) {
        self.windows
            .filter {$0.isKeyWindow}
            .first?
            .endEditing(force)
    }
}
/// The view modifier that hides an open keybaord on drag
struct ResignKeyboardOnDragGesture: ViewModifier {
    var gesture = DragGesture().onChanged {_ in
        UIApplication.shared.endEditing(true)
    }
    func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

extension View {
    /// Function with added the view modifier
    func resignKeyboardOnDragGesture() -> some View {
        return modifier(ResignKeyboardOnDragGesture())
    }
}
