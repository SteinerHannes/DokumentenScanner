//
//  BottomSheetView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 26.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

private enum Constants {
    /// The corner radius of the Bottomsheet
    static let radius: CGFloat = 16
    /// The snap ratio 
    static let snapRatio: CGFloat = 1.00
}

struct BottomSheetView<Content: View>: View {
    /// Is used to trigger the initaisation on appear only once
    @State private var initFirst: Bool = true
    /// It shows wether the bottom sheet is open
    @Binding var isOpen: Bool
    /// The calculated maximum height of the bottom sheet
    @Binding var maxHeight: CGFloat
    /// The calculated minimum height of the bottom sheet
    private let minHeight: CGFloat
    /// The content of the bottom sheet
    private let content: Content
    /// The tcalculated bottom safe area height (only exists on some devices)
    private var bottomSafeAreaHeight: CGFloat = 0.0

    /// The gesture state of the drag gesture
    @GestureState private var translation: CGFloat = 0

    /// Computed property for the verticaly offset of the bottom sheet
    private var offset: CGFloat {
        isOpen ? 0 : maxHeight - minHeight
    }

    /// The view over the content
    /// contains a trigger to open and close the bottom view
    private var indicator: some View {
        VStack(alignment: .center, spacing: 0) {
            Image(systemName: self.isOpen ? "chevron.compact.down" : "chevron.compact.up")
                .font(Font.system(size: 30, weight: .regular, design: .default))
                .foregroundColor(Color.secondary)
                .frame(height: 10, alignment: .center)
                .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                .animation(.default)
        }
        .frame(width: 100)
    }

    /**
     This method initializes th view
     - parameter isOpen: Binding bool from the parent view, to change the view from outside
     - parameter maxHeight: Binding CGFloat for the maximum height of the sheet
     - parameter content: The content of the bottom sheet
     */
    init(isOpen: Binding<Bool>, maxHeight: Binding<CGFloat>, @ViewBuilder content: () -> Content) {
        if #available(iOS 13.0, *) {
            bottomSafeAreaHeight += UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0
        }
        self.minHeight = bottomSafeAreaHeight + 10
        self._maxHeight = maxHeight
        self.content = content()
        self._isOpen = isOpen
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                self.indicator
                    .onTapGesture {
                        self.isOpen.toggle()
                    }
                self.content
            }
            .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
            .background(Color.secondarySystemBackground)
            .cornerRadius(Constants.radius)
            .shadow(color: Color.black, radius: 20, x: 0, y: -14)
            .frame(height: geometry.size.height, alignment: .bottom)
            .offset(y: max(self.offset + self.translation, 0))
            .animation(.default)
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    state = value.translation.height
//                    print(value.translation.height)
                }.onEnded { value in
                    let snapDistance = self.maxHeight * Constants.snapRatio
                    guard abs(value.translation.height) > snapDistance else {
                        return
                    }
                    if !self.isOpen {
//                        print(value.translation.height)
                        self.isOpen = value.translation.height < 0
//                        print(value.translation.height < 0)
                    } else {
//                        print(value.translation.height)
                        self.isOpen = !(value.translation.height > 0)
//                        print(value.translation.height > 0)
                    }
                }
            )
        }.onAppear {
            // if the view appears the first time add the height of the bottom safe area
            if self.initFirst {
                self._maxHeight.wrappedValue += self.bottomSafeAreaHeight
                self.initFirst = false
            }
        }
    }
}

struct BottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        return BottomSheetView(isOpen: .constant(true), maxHeight: .constant(200)) {
            Rectangle().fill(Color.systemFill)
        }
        .edgesIgnoringSafeArea(.all)
        .colorScheme(.dark)
    }
}
