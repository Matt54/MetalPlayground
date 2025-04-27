//
//  HelloWorldMetalView.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/17/25.
//

import SwiftUI

struct HelloWorldMetalView: View {
    @State var stateManager = ComputeShaderStateManager(shaderDefinition: HelloWorldShader())
    var body: some View {
        MetalShaderProtocolView(stateManager: stateManager)
    }
}

struct HelloWorldShader: IsComputeShaderDefinition {
    var functionName: String = "helloWorld"
}

#Preview {
    HelloWorldMetalView()
}
