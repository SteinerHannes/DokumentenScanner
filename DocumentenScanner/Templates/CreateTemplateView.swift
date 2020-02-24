//
//  CreateTemplateView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 24.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

struct CreateTemplateView: View {
    @Binding var image:UIImage?
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct CreateTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        CreateTemplateView(image: .constant(UIImage()))
    }
}
