//
//  ActivityIndicator.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 03.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

/// UIView representable for the activity indicator
struct ActivityIndicator: UIViewRepresentable {

    /// The ActivityIndicator from UIKit
    typealias UIView = UIActivityIndicatorView
    /// It shos wether the Activitiy Indicator animates or not
    var isAnimating: Bool
    /// The configuration of the indicator see also 'UIActivityIndicatorView'
    var configuration = { (indicator: UIView) in }

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView { UIView() }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
        configuration(uiView)
    }
}

struct ActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicator(isAnimating: true)
    }
}

/// The view modifier for the configuration
extension View where Self == ActivityIndicator {
    internal func configure(_ configuration: @escaping (Self.UIView) -> Void) -> Self {
        Self.init(isAnimating: self.isAnimating, configuration: configuration)
    }
}
