//
//  CoordinatesMetalView.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/17/25.
//

import SwiftUI

struct CoordinatesMetalView: View {
    @State var stateManager = ComputeShaderStateManager(shaderDefinition: CoordinatesShader())
    var body: some View {
        MetalShaderProtocolView(stateManager: stateManager)
    }
}

struct CoordinatesShader: IsComputeShaderDefinition {
    var functionName: String = "coordinates"
}

#Preview {
    CoordinatesMetalView()
}
