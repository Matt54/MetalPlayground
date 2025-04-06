//
//  ComputeShaderStateManager.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/6/25.
//

import SwiftUI

@Observable
class ComputeShaderStateManager {
    var shaderDefinition: IsComputeShaderDefinition = ExampleShader1()
    
    /// values that change over time - could be unused (static shader), could be a single phase/time value, or could any number of values changing over time
    /// each shader definition can define some keys and will bookkeep their values as needed according to
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
        shaderDefinition.updateRuntimeProperties(&runtimeProperties, deltaTime: deltaTime)
    }
}
