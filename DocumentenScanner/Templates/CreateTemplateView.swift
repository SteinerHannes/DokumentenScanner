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
    @Binding var image:UIImage?
    
    private var width:CGFloat {
        return self.startPoint.x.distance(to: self.endPoint.x)
    }
    
    private var height:CGFloat {
        return self.startPoint.y.distance(to: self.endPoint.y)
    }
    
    enum DragState {
        case inactive
        case dragging(translation: CGSize)
        
        var translastion: CGSize {
            switch self {
            case .dragging(let translation):
                return translation
            default:
                return .zero
            }
        }
    }
    
    enum MagnificationState {
        case inactive
        case zooming(scale: CGFloat)
        
        var scale: CGFloat {
            switch self {
            case .zooming(let scale):
                return scale
            default:
                return CGFloat(1.0)
            }
        }
    }
    
    @GestureState var magnificationState = MagnificationState.inactive
    @State var viewMagnificationState = CGFloat(1.0)
    
    @GestureState var rectDragState:DragState = DragState.inactive
    @State var viewDragState:CGSize = .zero
    @State private var startPoint:CGPoint = .zero
    @State private var endPoint:CGPoint = .zero
    
    var translastionOffset:CGSize {
        return CGSize(width: viewDragState.width + rectDragState.translastion.width, height: viewDragState.height + rectDragState.translastion.height)
    }
    
    var magnificationScale: CGFloat {
        return viewMagnificationState * magnificationState.scale
    }
    
    var body: some View {
        let rectDragGesture = DragGesture()
            .updating($rectDragState) { value, state, transaction in
                state = .dragging(translation: value.translation)
                print("translation\(value.translation) ")
        }
        .onEnded { value in
            self.viewDragState.height += value.translation.height
            self.viewDragState.width += value.translation.width
            print("")
        }
        
        let drawDragGesture = DragGesture()
            .onEnded{ (dragValue) in
                self.endPoint = dragValue.location
                //print("end", self.endPoint)
        }
        .onChanged{ (dragValue) in
            self.startPoint = dragValue.startLocation
            self.viewDragState.height = dragValue.startLocation.y
            self.viewDragState.width = dragValue.startLocation.x
            self.endPoint = dragValue.location
            //print("drag", self.endPoint)
        }
        
        let magnificationGesture = MagnificationGesture()
        .updating($magnificationState) { value, state, transaction in
            state = .zooming(scale: value)
        }.onEnded { value in
            self.viewMagnificationState *= value
        }
        
        return NavigationView {
            ZStack(alignment: .topLeading) {
                Image(uiImage: self.image ?? UIImage(imageLiteralResourceName: "post"))
                    .resizable()
                    .scaledToFit()
                Rectangle()
                    .stroke()
                    .background(Color.red.opacity(0.1))
                    .frame(width: self.width, height: self.height, alignment: .topLeading)
                    .offset(translastionOffset)
                    .gesture(rectDragGesture)
                
                
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .gesture(drawDragGesture)
            .scaleEffect(magnificationScale)
            .gesture(magnificationGesture)
        }
    }
}

//struct CreateTemplateView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateTemplateView(image: .constant(UIImage()))
//    }
//}
