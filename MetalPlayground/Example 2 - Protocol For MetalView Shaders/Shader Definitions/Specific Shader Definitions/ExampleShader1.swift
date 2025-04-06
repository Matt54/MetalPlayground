//
//  ExampleShader1.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/6/25.
//

import Foundation

struct ExampleShader1: IsComputeShaderDefinition {
    var functionName: String = "exampleComputeShader1"
    var setByteLength: Int = MemoryLayout<ExampleComputeShader1Params>.stride
    var animationRate: Double = 1.0
    var hueRotateRate: Double = 1.0
    
    struct ExampleComputeShaderRuntimeParams {
        var animationPhase: Double = 0
        var hueRotatePhase: Double = 0
    }

    func withParameters<T>(_ properties: [String: Any], _ body: (UnsafeRawPointer) -> T) -> T {
        let runtimeParams = properties["runtimeParams"] as? ExampleComputeShaderRuntimeParams ?? ExampleComputeShaderRuntimeParams()
        var params = ExampleComputeShader1Params(animationPhase: Float(runtimeParams.animationPhase),
                                                 hueRotatePhase: Float(runtimeParams.hueRotatePhase))
        return withUnsafePointer(to: &params) {
            body(UnsafeRawPointer($0))
        }
    }
    
    func updateRuntimeProperties(_ properties: inout [String: Any], deltaTime: Double) {
        if let runtimeParams = properties["runtimeParams"] as? ExampleComputeShaderRuntimeParams  {
            let animationPhase = runtimeParams.animationPhase + animationRate * deltaTime
            let hueRotatePhase = runtimeParams.hueRotatePhase + hueRotateRate * deltaTime
            properties["runtimeParams"] = ExampleComputeShaderRuntimeParams(animationPhase: animationPhase,
                                                                            hueRotatePhase: hueRotatePhase)
        } else {
            properties["runtimeParams"] = ExampleComputeShaderRuntimeParams()
        }
    }
}
