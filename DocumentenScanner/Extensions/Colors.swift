//
//  Colors.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 26.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import SwiftUI

extension Color {
    // Label Colors
    public static let label: Color = Color(UIColor.label)
    public static let secondaryLabel: Color = Color(UIColor.secondaryLabel)
    public static let tertiaryLabel: Color = Color(UIColor.tertiaryLabel)
    public static let quaternaryLabel: Color = Color(UIColor.quaternaryLabel)
    // Fill Colors
    public static let systemFill: Color = Color(UIColor.systemFill)
    public static let secondarySystemFill: Color = Color(UIColor.secondarySystemFill)
    public static let tertiarySystemFill: Color = Color(UIColor.tertiarySystemFill)
    public static let quaternarySystemFill: Color = Color(UIColor.quaternarySystemFill)
    // Background Colors
    public static let systemBackground: Color = Color(UIColor.systemBackground)
    public static let secondarySystemBackground: Color = Color(UIColor.secondarySystemBackground)
    public static let tertiarySystemBackground: Color = Color(UIColor.tertiarySystemBackground)
    // Text Colors
    public static let placeholderText: Color = Color(UIColor.placeholderText)
    public static let lightText: Color = Color(UIColor.lightText)

    public static let shadow: Color = Color.init(hue: 0, saturation: 0, brightness: 0.7)
}
