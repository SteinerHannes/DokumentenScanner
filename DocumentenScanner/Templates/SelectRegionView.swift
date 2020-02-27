//
//  SelectRegionView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 26.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

struct SelectRegionView: View {
    @EnvironmentObject var appState:AppState
    @Environment(\.presentationMode) var presentation:Binding<PresentationMode>
    
    /// State for the Longpress-Drag-Gesture
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
    
    /// State for moving  the rectangle
    enum DragState {
        case inactive
        case dragging(translation: CGSize)
        
        var translation: CGSize {
            switch self {
            case .dragging(let translation):
                return translation
            default:
                return .zero
            }
        }
    }
    
    /// State for the Zoom-Gesture
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
    
    /// Zoom gesture state
    @GestureState var magnificationState = MagnificationState.inactive
    /// Zoom variable
    @State var viewMagnificationState = CGFloat(1.0)
    
    /// Drag gesture state for the rectangle
    @GestureState var rectDragState:DragState = DragState.inactive
    /// Position of the rectangle
    @State var rectState:CGSize = .zero
    
    /// Position of the container
    @State var imageState:CGSize = .zero
    
    /// Longpress-Drag gesture state for drawing the rectangle
    @GestureState var drawState = DrawState.inactive
    /// Starting point of the rectangle. Important for the calculation of the width and height of the rect
    @State private var startPoint:CGPoint = .zero
    /// Ending point of the rectangle. Important for the calculation of the width and height of the rect
    @State private var endPoint:CGPoint = .zero
    
    /// Width of the rectangle
    private var width:CGFloat {
        return self.startPoint.x.distance(to: self.endPoint.x)
    }
    /// Height of the rectangle
    private var height:CGFloat {
        return self.startPoint.y.distance(to: self.endPoint.y)
    }
    /// Offset of the image to the coordinate origin (current position + the translation of the last drag gesture)
    private var imageTranslastionOffset:CGSize {
        return CGSize(width: imageState.width, height: imageState.height)
    }
    /// Offset of the rectangle to the coordinate origin
    private var rectTranslastionOffset:CGSize {
        return CGSize(width: rectState.width + rectDragState.translation.width, height: rectState.height + rectDragState.translation.height)
    }
    /// New zoom level according to gesture
    private var magnificationScale: CGFloat {
        return viewMagnificationState * magnificationState.scale
    }
    
    @State var isShowingPopOver:Bool = false
    @State var isNoRectSet:Bool = false
    
    var body: some View {
        let rectDragGesture = DragGesture()
            .updating($rectDragState) { value, state, transaction in
                state = .dragging(translation: value.translation)
            }
            // Adding the translastion of the gesture to the position
            .onEnded { value in
                self.rectState.height += value.translation.height
                self.rectState.width += value.translation.width
            }
        
        let imageDragGesture = DragGesture()
            // Adding the translastion of the gesture to the position
            .onChanged { value in
                self.imageState.height += value.translation.height
                self.imageState.width += value.translation.width
            }
            .onEnded { value in
                self.imageState.height += value.translation.height
                self.imageState.width += value.translation.width
            }
        
        let minimumLongPressDuration = 0.3
        let longPressDraw = LongPressGesture(minimumDuration: minimumLongPressDuration)
            // It takes a third of a second for the gesture to trigger the drag gesture
            .sequenced(before: DragGesture())
            .updating($drawState) { value, state, transaction in
                switch value {
                // Long press begins
                case .first(true):
                    state = .pressing
                // Long press confirmed, dragging may begin
                case .second(true, let drag):
                    state = .dragging(translation: drag?.translation ?? .zero)
                // Dragging ended or the long press cancelled
                default:
                    state = .inactive
                }
            }
            .onEnded { value in
                guard case .second(true, let drag?) = value else { return }
                // Set endpoint for calculating w+h
                self.endPoint = drag.location
                
            }
            .onChanged { value in
                switch value {
                case .second(true, let drag):
                    guard drag != nil else { return }
                    // set startpoint for the calculating w+h
                    self.startPoint = drag!.startLocation
                    // set the position of the rect
                    self.rectState.height = drag!.startLocation.y
                    self.rectState.width = drag!.startLocation.x
                    // set endpoint to the current location for the calculating w+h
                    self.endPoint = drag!.location
                default:
                    return
                }
            }
        
        let magnificationGesture = MagnificationGesture()
            .updating($magnificationState) { value, state, transaction in
                // set zoom level change
                state = .zooming(scale: value)
            }.onEnded { value in
                // set the zoom level
                self.viewMagnificationState *= value
            }
        
        return HStack {
            ZStack(alignment: .bottomTrailing) {
                ZStack(alignment: .topLeading) {
                    Group{
                        Image(uiImage: self.appState.image ?? UIImage(imageLiteralResourceName: "post"))
                            .resizable()
                            .scaledToFit()
                            .gesture(longPressDraw)
                            .gesture(imageDragGesture)
                            .shadow(color: Color.init(hue: 0, saturation: 0, brightness: 0.7), radius: 20, x: 0, y: 0)
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
                popOverButton
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .gesture(magnificationGesture)
        .navigationBarTitle("Wähle eine Region", displayMode: .inline)
        //.navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton(),trailing: saveButton())
    }
    
    private var popOverButton: some View {
        Group{
            Button(action: {
                self.isShowingPopOver = true
            }) {
                ZStack(alignment: .center) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 50, weight: .regular, design: .default))
                        .foregroundColor(Color.red)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 20))
                    .opacity(0.8)
                }
            }
            if( self.isShowingPopOver ){
                self.popOverView
            }
        }
    }
    
    private var popOverView: some View {
        ZStack(alignment: .center){
            Color.gray.opacity(0.5)
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 2){
                    Text("Wie der Spaß hier funktioniert...")
                    .font(Font.system(size: 16, weight: .semibold, design: .default))
                    Group{
                        Text("Bild verschieben")
                        Text("Region einzeichnen")
                        Text("Region verschieben")
                        Text("Zoom...")
                    }.font(Font.system(size: 13, weight: .regular, design: .default))
                }
                .padding()
                Divider()
                Button(action: { self.isShowingPopOver = false }){
                    Text("Verstanden!")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(Color.tertiarySystemBackground)
                        .font(Font.system(size: 16, weight: .semibold , design: .default))
                }
            }
            .frame(width: UIScreen.main.bounds.width-64, alignment: .leading)
            .background(Color.systemBackground)
            .cornerRadius(15)
        }
    }
    
    private func backButton() -> some View {
        Button(action: {
            self.presentation.wrappedValue.dismiss()
        }){
            Text("Zurück")
        }
    }
    
    private func saveButton() -> some View {
        Button(action: {
            if(self.rectState.equalTo(.zero)){
                self.isNoRectSet = true
            }else{
                if self.appState.maxHeight < 140+3*45 {
                    self.appState.maxHeight += 45
                }
                self.appState.currentAttribut!.height = self.height
                self.appState.currentAttribut!.width = self.width
                self.appState.currentAttribut!.rectState = self.rectState
                self.appState.attributList.append(self.appState.currentAttribut!)
                self.appState.currentAttribut = nil
                self.appState.showRoot = false
            }
        }){
            Text("Speichern")
        }
        .alert(isPresented: self.$isNoRectSet) {
            Alert(title: Text("Es wurde keine Region markiert"),
                  message: Text("Wähle eine Region aus, um das Attribut zu speichern."),
                  dismissButton: .cancel(Text("Ok")) )
        }
    }
}

struct SelectRegionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SelectRegionView().environmentObject(AppState())
        }
    }
}