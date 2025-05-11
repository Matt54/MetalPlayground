//
//  SDFShader.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 5/11/25.
//

import Foundation

struct SDFShader: IsComputeShaderDefinitionWithParameters, Codable {
    var functionName: String = "sdfDrawing"
    var setByteLength: Int = MemoryLayout<SDFParams>.stride
    var shouldMask: Bool = false
    var selectedShape: SDFShape = .circle
    var intensity: Float = 1.0
    var repetitions: Float = 1.0
    var shouldFlipAlternating: Bool = false
    var rotation: Float = 0.0
    var blendK: Float = 0.0
    var isRotating: Bool = false
    var rotationSpeed: Float = 1.0
    var scale: Float = 0.5
    var shouldMakeAnnular: Bool = false
    var shellThickness: Float = 0.05
    var shouldApplyPattern: Bool = false
    var patternFrequency: Float = 5.0
    var patternPhase: Float = 0
    var isPatternAnimated: Bool = false
    var patternAnimationSpeed: Float = 1.0
    var contrast: Float = 1.0

    func withParameters<T>(_ properties: [String: Any], _ body: (UnsafeRawPointer) -> T) -> T {
        var params = SDFParams(
            shouldMask: shouldMask ? 1 : 0,
            shape: selectedShape.metalShape,
            intensity: intensity,
            repetitions: SIMD2<Float>(repetitions, repetitions),
            shouldFlipAlternating: shouldFlipAlternating ? 1 : 0,
            rotation: rotation + (properties["autoRotateAmount"] as? Float ?? 0),
            blendK: blendK,
            scale: scale,
            shellThickness: shellThickness,
            shouldMakeAnnular: shouldMakeAnnular ? 1 : 0,
            patternFrequency: patternFrequency,
            shouldApplyPattern: shouldApplyPattern ? 1 : 0,
            patternPhase: patternPhase + (properties["autoPatternPhase"] as? Float ?? 0),
            contrast: contrast
        )
        return withUnsafePointer(to: &params) {
            body(UnsafeRawPointer($0))
        }
    }
    
    func updateRuntimeProperties(_ properties: inout [String: Any], deltaTime: Double) {
        if isRotating {
            if var autoRotateAmount = properties["autoRotateAmount"] as? Float {
                autoRotateAmount +=  Float(deltaTime) * rotationSpeed
                properties["autoRotateAmount"] = autoRotateAmount
            } else {
                properties["autoRotateAmount"] = rotationSpeed * Float(deltaTime)
            }
        }

        if isPatternAnimated {
            if var autoPatternPhase = properties["autoPatternPhase"] as? Float {
                autoPatternPhase += Float(deltaTime) * patternAnimationSpeed
                properties["autoPatternPhase"] = autoPatternPhase
            } else {
                properties["autoPatternPhase"] = patternAnimationSpeed * Float(deltaTime)
            }
        }
    }
}
