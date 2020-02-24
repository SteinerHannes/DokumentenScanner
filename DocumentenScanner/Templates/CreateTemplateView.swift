//
//  CreateTemplateView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 24.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import Foundation

struct CreateTemplateView: View {
    //@Binding var image:UIImage?
    @State private var startPoint:CGPoint = .zero
    @State private var endPoint:CGPoint = .zero
    @State private var isDragging:Bool = false
    @State private var isDraggingRect:Bool = false
    @State private var oldDragTranslation: CGSize = .zero
    
    private var width:CGFloat {
        return self.startPoint.x.distance(to: self.endPoint.x)
    }
    
    private var height:CGFloat {
        return self.startPoint.y.distance(to: self.endPoint.y)
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                Color.blue
                Text("asd")
                //                    Image(uiImage: self.image ?? UIImage())
                //                    .resizable()
                //                    .scaledToFit()
                Rectangle()
                    .background(Color.blue)
                    .frame(width: self.width, height: self.height, alignment: .topLeading)
                    .offset(x: self.startPoint.x, y: self.startPoint.y)
                    .gesture(DragGesture()
                        .onChanged({ (dragValue) in
                            self.isDraggingRect = true
                            // MARK: TODO
                        })
                        .onEnded({ (dragValue) in
                            self.isDraggingRect = false
                        })
                    )
                    .onLongPressGesture{
                        self.startPoint = .zero
                        self.endPoint = .zero
                    }

            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .gesture(DragGesture()
                .onEnded({ (dragValue) in
                    if !self.isDraggingRect {
                        self.endPoint = dragValue.location
                        self.isDragging = false
                        print("end", self.endPoint)
                    }
                })
                .onChanged({ (dragValue) in
                    if !self.isDraggingRect {
                        self.startPoint = dragValue.startLocation
                        self.endPoint = dragValue.location
                        print("drag", self.endPoint)
                    }
                })
            )
            //            GeometryReader { proxy in
            //
            //            }
        }
    }
}

//struct CreateTemplateView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateTemplateView(image: .constant(UIImage()))
//    }
//}
