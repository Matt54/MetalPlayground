//
//  PolarColorGradientView.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/27/25.
//

import SwiftUI

struct PolarColorGradientShader: IsComputeShaderDefinition {
    var functionName: String = "polarColorGradient"
}

struct PolarColorGradientView: View {
    let stateManager = ComputeShaderStateManager(shaderDefinition: PolarColorGradientShader())
    
    var body: some View {
        VStack {
            MetalShaderProtocolView(stateManager: stateManager)
                .aspectRatio(1.0, contentMode: .fit)
                .clipShape(Circle())
        }
    }
}

#Preview {
    PolarColorGradientView()
}
