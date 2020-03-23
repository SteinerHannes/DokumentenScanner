//
//  SelectRegionView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 26.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

//swiftlint:disable multiple_closures_with_trailing_closure
struct SelectRegionView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>

    @Binding var showRoot: Bool
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
    @State var viewMagnificationState: CGFloat = 1.0

    /// Drag gesture state for the rectangle
    @GestureState var rectDragState: DragState = DragState.inactive
    /// Position of the rectangle
    @State var rectState: CGSize = .zero

    /// Position of the container
    @State var imageState: CGSize = .zero

    /// Longpress-Drag gesture state for drawing the rectangle
    @GestureState var drawState = DrawState.inactive
    /// Starting point of the rectangle. Important for the calculation of the width and height of the rect
    @State private var startPoint: CGPoint = .zero
    /// Ending point of the rectangle. Important for the calculation of the width and height of the rect
    @State private var endPoint: CGPoint = .zero

    /// Width of the rectangle
    private var width: CGFloat {
        return self.startPoint.x.distance(to: self.endPoint.x)
    }
    /// Height of the rectangle
    private var height: CGFloat {
        return self.startPoint.y.distance(to: self.endPoint.y)
    }
    /// Offset of the image to the coordinate origin
    /// (current position + the translation of the last drag gesture)
    private var imageTranslastionOffset: CGSize {
        return CGSize(width: imageState.width, height: imageState.height)
    }
    /// Offset of the rectangle to the coordinate origin
    private var rectTranslastionOffset: CGSize {
        return CGSize(width: rectState.width + rectDragState.translation.width,
                      height: rectState.height + rectDragState.translation.height)
    }
    /// New zoom level according to gesture
    private var magnificationScale: CGFloat {
        return viewMagnificationState * magnificationState.scale
    }

    @State var isShowingPopOver: Bool = false
    @State var isNoRectSet: Bool = false

    @State var zoomPoint: UnitPoint = .center

    init(showRoot: Binding<Bool>) {
        print("init SelectRegionView")
        self._showRoot = showRoot
    }

    var body: some View {
        let rectDragGesture = DragGesture()
            .updating($rectDragState) { value, state, _ in
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
            .updating($drawState) { value, state, _ in
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
            .updating($magnificationState) { value, state, _ in
                // set zoom level change
                state = .zooming(scale: value)
            }.onEnded { value in
                // set the zoom level
                self.viewMagnificationState = max(min(self.viewMagnificationState * value, 1.5), 0.06)
                print(self.viewMagnificationState)
            }
//        .simultaneously(with: DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged({ value in
//            self.zoomPoint = UnitPoint(x: value.startLocation.x, y: value.startLocation.y)
//            print("point",self.zoomPoint.x)
//        }))

        return VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                ZStack(alignment: .topLeading) {
                    Group {
                        Image(uiImage: self.store.states.newTemplateState.image
                            ?? UIImage(imageLiteralResourceName: "post"))
                            .frame(alignment: .center)
                            .gesture(longPressDraw)
                            .gesture(imageDragGesture)
                            .shadow(color: .shadow, radius: 20, x: 0, y: 0)
                            .frame(alignment: .topLeading)
                        Rectangle()
                            .stroke(Color.label, lineWidth: 3)
                            .background(Color.blue.opacity(0.1))
                            .frame(width: self.width, height: self.height, alignment: .topLeading)
                            .offset(rectTranslastionOffset)
                            .gesture(rectDragGesture)
                    }
                    .offset(imageTranslastionOffset)
                }
                .scaleEffect(magnificationScale, anchor: self.zoomPoint )
                popOverButton
                    .frame(alignment: .bottomTrailing)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .gesture(magnificationGesture)
        .navigationBarTitle("Wähle eine Region", displayMode: .inline)
        .navigationBarItems(trailing: trailingItem())
        .onAppear {
            self.zoomPoint = .topLeading
            self.viewMagnificationState = (UIScreen.main.bounds.width /
                (self.store.states.newTemplateState.image?.size.width ?? 1 ))
            self.zoomPoint = .center
        }
    }

    private var popOverButton: some View {
        Group {
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
            if self.isShowingPopOver {
                self.popOverView
            }
        }
    }

    private var popOverView: some View {
        ZStack(alignment: .center) {
            Color.gray.opacity(0.5)
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Wie der Spaß hier funktioniert...")
                    .font(Font.system(size: 16, weight: .semibold, design: .default))
                    Group {
                        Text("Bild verschieben")
                        Text("Region einzeichnen")
                        Text("Region verschieben")
                        Text("Zoom...")
                    }.font(Font.system(size: 13, weight: .regular, design: .default))
                }
                .padding()
                Divider()
                Button(action: { self.isShowingPopOver = false }) {
                    Text("Verstanden!")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(Color.tertiarySystemBackground)
                        .font(Font.system(size: 16, weight: .semibold, design: .default))
                }
            }
            .frame(width: UIScreen.main.bounds.width-64, alignment: .leading)
            .background(Color.systemBackground)
            .cornerRadius(15)
        }
    }

    private func trailingItem() -> some View {
        Button(action: {
            if self.rectState.equalTo(.zero) {
                self.isNoRectSet = true
            } else {

                self.store.send(.newTemplate(action:
                    .setRegionAndAddAttributeToPage(height: self.height,
                                                    width: self.width,
                                                    rectState: self.rectState)))
                self.showRoot = false
            }
        }) {
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
            SelectRegionView(showRoot: .constant(false))
                .environmentObject(AppStoreMock.getAppStore())
        }
    }
}
