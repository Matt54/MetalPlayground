//
//  ColorPickerMetalView.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/17/25.
//

import SwiftUI

struct ColorPickerMetalView: View {
    let stateManager = ComputeShaderStateManager(shaderDefinition: ColorPickerShader())
    
    var body: some View {
        VStack {
            MetalShaderProtocolView(stateManager: stateManager)
            
            let typedBinding = Binding<ColorPickerShader>(
                get: { stateManager.shaderDefinition as! ColorPickerShader },
                set: { stateManager.shaderDefinition = $0 }
            )
            
            ColorAdjustmentView(colorShader: typedBinding)
                .padding()
        }
    }
    
    struct ColorAdjustmentView: View {
        @Binding var colorShader: ColorPickerShader
        
        var body: some View {
            ColorPicker("Color", selection: $colorShader.color)
        }
    }
}

#Preview {
    ColorPickerMetalView()
}
