//
//  IsComputeShaderDefinition.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/6/25.
//

import Foundation

protocol IsComputeShaderDefinition: Codable {
    var functionName: String { get }
    var setByteLength: Int { get }
    func withParameters<T>(_ properties: [String: Any], _ body: (UnsafeRawPointer) -> T) -> T
    func updateRuntimeProperties(_ properties: inout [String: Any], deltaTime: Double)
}
