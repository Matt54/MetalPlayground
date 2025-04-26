//
//  ComputeShaderStateManager.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/6/25.
//

import SwiftUI

@Observable
class ComputeShaderStateManager {
    init(shaderDefinition: IsComputeShaderDefinition = ExampleShader1()) {
        self.shaderDefinition = shaderDefinition
    }
    
    var shaderDefinition: IsComputeShaderDefinition
    
    /// values that change over time - could be unused (static shader), could be a single phase/time value, or could any number of values changing over time
    /// each shader definition can define some keys and will bookkeep their values as needed
    var runtimeProperties: [String: Any] = [:]
    
    func updateProperties() {
        var deltaTime: Double
        let currentTime = CACurrentMediaTime()
        if let lastUpdateTime = runtimeProperties["lastUpdateTime"] as? Double {
            deltaTime = currentTime - lastUpdateTime
        } else {
            deltaTime = 0
        }
        updateProperties(deltaTime: deltaTime)
        runtimeProperties["lastUpdateTime"] = currentTime
    }
    
    func updateProperties(deltaTime: Double) {
        if let shaderDefinition = shaderDefinition as? IsComputeShaderDefinitionWithParameters {
            shaderDefinition.updateRuntimeProperties(&runtimeProperties, deltaTime: deltaTime)
        }
    }
}
