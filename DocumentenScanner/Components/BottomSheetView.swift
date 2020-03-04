//
//  BottomSheetView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 26.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

private enum Constants {
    static let radius: CGFloat = 16
    static let snapRatio: CGFloat = 0.30
}

struct BottomSheetView<Content: View>: View {
    @State private var initFirst: Bool = true
    @Binding var isOpen: Bool
    @Binding var maxHeight: CGFloat
    private let minHeight: CGFloat
    private let content: Content
    private var tempMinHeight: CGFloat = 0.0
    
    @GestureState private var translation: CGFloat = 0
    
    private var offset: CGFloat {
        isOpen ? 0 : maxHeight - minHeight
    }
    
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
    
    init(isOpen: Binding<Bool>, maxHeight: Binding<CGFloat>, @ViewBuilder content: () -> Content) {
        if #available(iOS 13.0, *) {
            tempMinHeight += UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0
        }
        self.minHeight = tempMinHeight + 10
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
            if self.initFirst {
                self._maxHeight.wrappedValue += self.tempMinHeight
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
