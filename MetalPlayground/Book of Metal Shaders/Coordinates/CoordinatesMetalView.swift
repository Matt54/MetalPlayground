//
//  CoordinatesMetalView.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/17/25.
//

import SwiftUI

struct CoordinatesMetalView: View {
    var body: some View {
        StaticMetalView(functionName: "coordinates")
            .aspectRatio(contentMode: .fit)
    }
}

#Preview {
    CoordinatesMetalView()
}
