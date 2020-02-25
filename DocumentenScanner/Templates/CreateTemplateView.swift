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
    
    enum DrawState {
        case inactive
        case pressing
        case dragging(translation: CGSize)
        
        var translation: CGSize {
            switch self {
            case .inactive, .pressing:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }
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
    @State var rectState:CGSize = .zero
    
    @GestureState var imageDragState:DragState = DragState.inactive
    @State var imageState:CGSize = .zero
    
    @GestureState var drawState = DrawState.inactive
    @State private var startPoint:CGPoint = .zero
    @State private var endPoint:CGPoint = .zero
    
    private var width:CGFloat {
        return self.startPoint.x.distance(to: self.endPoint.x)
    }
    
    private var height:CGFloat {
        return self.startPoint.y.distance(to: self.endPoint.y)
    }
    
    private var imageTranslastionOffset:CGSize {
        return CGSize(width: imageState.width + imageDragState.translastion.width, height: imageState.height + imageDragState.translastion.height)
    }
    
    private var rectTranslastionOffset:CGSize {
        return CGSize(width: rectState.width + rectDragState.translastion.width, height: rectState.height + rectDragState.translastion.height)
    }
    
    private var magnificationScale: CGFloat {
        return viewMagnificationState * magnificationState.scale
    }
    
    var body: some View {
        let rectDragGesture = DragGesture()
            .updating($rectDragState) { value, state, transaction in
                print("rect update")
                state = .dragging(translation: value.translation)
                //print("translation\(value.translation) ")
            }
            .onEnded { value in
                print("rect end")
                self.rectState.height += value.translation.height
                self.rectState.width += value.translation.width
            }
        
        let imageDragGesture = DragGesture()
            .updating($imageDragState) { value, state, transaction in
                print("image update")
                state = .dragging(translation: value.translation)
                //print("translation\(value.translation) ")
            }
            .onEnded { value in
                print("image end")
                self.imageState.height += value.translation.height
                self.imageState.width += value.translation.width
            }
        
        let minimumLongPressDuration = 0.3
        let longPressDraw = LongPressGesture(minimumDuration: minimumLongPressDuration)
            .sequenced(before: DragGesture())
            .updating($drawState) { value, state, transaction in
                print("draw update")
                switch value {
                // Long press begins.
                case .first(true):
                    print("pressing")
                    state = .pressing
                // Long press confirmed, dragging may begin.
                case .second(true, let drag):
                    print("dragging")
                    state = .dragging(translation: drag?.translation ?? .zero)
                // Dragging ended or the long press cancelled.
                default:
                    print("inactive")
                    state = .inactive
                }
            }
            .onEnded { value in
                print("draw end")
                guard case .second(true, let drag?) = value else { return }
                self.endPoint = drag.location
                
            }
            .onChanged { value in
                print("draw change")
                switch value {
                case .second(true, let drag):
                    print("second")
                    guard drag != nil else { return }
                    self.startPoint = drag!.startLocation
                    self.rectState.height = drag!.startLocation.y
                    self.rectState.width = drag!.startLocation.x
                    self.endPoint = drag!.location
                
                case .first(let bla):
                    print("first", bla)
                case .second(false, _):
                    print("second false")
                }
            }
        
        let magnificationGesture = MagnificationGesture()
            .updating($magnificationState) { value, state, transaction in
                print("zoom update")
                state = .zooming(scale: value)
            }.onEnded { value in
                print("zoom end")
                self.viewMagnificationState *= value
            }
        
        return NavigationView {
            ZStack(alignment: .topLeading) {
                Group{
                    Image(uiImage: self.image ?? UIImage(imageLiteralResourceName: "post"))
                        .resizable()
                        .scaledToFit()
                        .gesture(longPressDraw)
                        .gesture(imageDragGesture)
                    Rectangle()
                        .stroke()
                        .background(Color.red.opacity(0.1))
                        .frame(width: self.width, height: self.height, alignment: .topLeading)
                        .offset(rectTranslastionOffset)
                        .gesture(rectDragGesture)
                }
                .offset(imageTranslastionOffset)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .scaleEffect(magnificationScale)
            
        }
        .gesture(magnificationGesture)
    }
}

//struct CreateTemplateView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateTemplateView(image: .constant(UIImage()))
//    }
//}
