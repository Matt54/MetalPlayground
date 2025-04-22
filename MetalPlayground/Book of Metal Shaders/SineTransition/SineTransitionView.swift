//
//  SineTransitionView.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/17/25.
//

import SwiftUI

struct SineTransitionView: View {
    let stateManager = ComputeShaderStateManager(shaderDefinition: SineTransitionShader())
    
    var body: some View {
        VStack {
            MetalShaderProtocolView(stateManager: stateManager)
            
            let typedBinding = Binding<SineTransitionShader>(
                get: { stateManager.shaderDefinition as! SineTransitionShader },
                set: { stateManager.shaderDefinition = $0 }
            )
            
            ColorAdjustmentView(shader: typedBinding)
                .padding()
        }
    }
    
    struct ColorAdjustmentView: View {
        @Binding var shader: SineTransitionShader
        
        var body: some View {
            VStack {
                Text("Animation Rate")
                Slider(value: $shader.transitionRate, in: 0...4.0)
            }
        }
    }
}

#Preview {
    SineTransitionView()
}
