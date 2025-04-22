//
//  ColorPickerShader.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/17/25.
//

import SwiftUI
import simd

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
typealias PlatformColor = UIColor
#elseif os(macOS)
import AppKit
typealias PlatformColor = NSColor
#endif

extension Color {
    var rgbaSIMD: simd_float4? {
        #if os(macOS)
        guard let cgColor = PlatformColor(self).cgColor,
              let components = cgColor.components else {
            return nil
        }

        let r = Float(components[safe: 0] ?? 0)
        let g = Float(components[safe: 1] ?? 0)
        let b = Float(components.count >= 3 ? components[2] : components[1])
        let a = Float(cgColor.alpha)
        return simd_float4(r, g, b, a)

        #else
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        guard PlatformColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        return simd_float4(Float(red), Float(green), Float(blue), Float(alpha))
        #endif
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

struct ColorPickerShader: IsComputeShaderDefinition {
    var functionName: String = "colorPickerShader"
    var setByteLength: Int = MemoryLayout<ColorPickerParams>.stride
    var color: Color = .green

    func withParameters<T>(_ properties: [String: Any], _ body: (UnsafeRawPointer) -> T) -> T {
        var params = ColorPickerParams(color: color.rgbaSIMD ?? simd_float4(0.0,0.0,0.0,0.0))
        return withUnsafePointer(to: &params) {
            body(UnsafeRawPointer($0))
        }
    }
    
    func updateRuntimeProperties(_ properties: inout [String: Any], deltaTime: Double) { }
}
