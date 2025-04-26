//
//  ExampleShader2.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/6/25.
//

import Foundation

struct ExampleShader2: IsComputeShaderDefinitionWithParameters, Codable {
    var functionName: String = "exampleComputeShader2"
    var setByteLength: Int = MemoryLayout<ExampleComputeShader2Params>.stride
    var animationRate: Double = 1.0
    var hueRotateRate: Double = 1.0
    var isBox: Bool = false
    
    struct ExampleComputeShaderRuntimeParams {
        var animationPhase: Double = 0
        var hueRotatePhase: Double = 0
    }

    func withParameters<T>(_ properties: [String: Any], _ body: (UnsafeRawPointer) -> T) -> T {
        let runtimeParams = properties["runtimeParams"] as? ExampleComputeShaderRuntimeParams ?? ExampleComputeShaderRuntimeParams()
        var params = ExampleComputeShader2Params(animationPhase: Float(runtimeParams.animationPhase),
                                                 hueRotatePhase: Float(runtimeParams.hueRotatePhase),
                                                 isBox: Int32(isBox ? 1 : 0))
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
