//
//  SineTransitionShader.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/17/25.
//

import Foundation

struct SineTransitionShader: IsComputeShaderDefinition {
    var functionName: String = "sineTransition"
    var setByteLength: Int = MemoryLayout<SineTransitionParams>.stride
    var transitionRate: Double = 1.0
    
    struct SineTransitionRuntimeParams {
        var phase: Double = 0
    }

    func withParameters<T>(_ properties: [String: Any], _ body: (UnsafeRawPointer) -> T) -> T {
        let phase = properties["phase"] as? Double ?? 0.0
        var params = SineTransitionParams(phase: Float(phase))
        return withUnsafePointer(to: &params) {
            body(UnsafeRawPointer($0))
        }
    }
    
    func updateRuntimeProperties(_ properties: inout [String: Any], deltaTime: Double) {
        if let phase = properties["phase"] as? Double  {
            let nextPhase = phase + transitionRate * deltaTime
            properties["phase"] = nextPhase
        } else {
            properties["phase"] = 0.0
        }
    }
}
