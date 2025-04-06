//
//  DistanceFieldShader.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/6/25.
//

import Foundation

struct DistanceFieldShader: IsComputeShaderDefinition, Codable {
    var functionName: String = "distanceField"
    var setByteLength: Int = MemoryLayout<DistanceFieldParams>.stride
    var width: Float = 0.25

    func withParameters<T>(_ properties: [String: Any], _ body: (UnsafeRawPointer) -> T) -> T {
        var params = DistanceFieldParams(width: width)
        return withUnsafePointer(to: &params) {
            body(UnsafeRawPointer($0))
        }
    }
    
    func updateRuntimeProperties(_ properties: inout [String: Any], deltaTime: Double) { }
}
