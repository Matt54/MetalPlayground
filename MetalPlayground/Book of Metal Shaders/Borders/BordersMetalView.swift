//
//  BordersMetalView.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 5/4/25.
//

import SwiftUI

struct BordersShader: IsComputeShaderDefinition {
    var functionName: String = "borders"
}

struct BordersMetalView: View {
    let stateManager = ComputeShaderStateManager(shaderDefinition: BordersShader())
    
    var body: some View {
        VStack {
            MetalShaderProtocolView(stateManager: stateManager)
        }
    }
}

#Preview {
    BordersMetalView()
}
