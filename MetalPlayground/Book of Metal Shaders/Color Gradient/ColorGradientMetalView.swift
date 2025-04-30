//
//  ColorGradientMetalView.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/27/25.
//

import SwiftUI

struct ColorGradientShader: IsComputeShaderDefinition {
    var functionName: String = "colorGradient"
}

struct ColorGradientMetalView: View {
    let stateManager = ComputeShaderStateManager(shaderDefinition: ColorGradientShader())
    
    var body: some View {
        VStack {
            MetalShaderProtocolView(stateManager: stateManager)
        }
    }
}

#Preview {
    ColorGradientMetalView()
}
