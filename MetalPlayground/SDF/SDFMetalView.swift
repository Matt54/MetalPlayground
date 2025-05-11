//
//  SDFMetalView.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 5/4/25.
//

import SwiftUI

enum SDFShape: Int, CaseIterable {
    case circle = 0
    case box = 1
    case triangle = 2
    case roundedBox = 3
    case regularPolygon = 4
    case line = 5
    case capsule = 6
    case ellipse = 7
    case cross = 8
    case pentagram = 9
    case unevenCapsule = 10
    case heart = 11
    case pie = 12
    
    var metalShape: SDFPrimitive {
        SDFPrimitive(rawValue: UInt32(self.rawValue))
    }
    
    var displayName: String {
        switch self {
        case .circle: return "Circle"
        case .box: return "Box"
        case .triangle: return "Triangle"
        case .roundedBox: return "Rounded Box"
        case .regularPolygon: return "Hexagon"  // Since we're using 6 sides by default
        case .line: return "Line"
        case .capsule: return "Capsule"
        case .ellipse: return "Ellipse"
        case .cross: return "Cross"
        case .pentagram: return "Pentagram"
        case .unevenCapsule: return "Uneven Capsule"
        case .heart: return "Heart"
        case .pie: return "Pie"
        }
    }
}

struct SDFShader: IsComputeShaderDefinitionWithParameters {
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
            shouldMakeAnnular: shouldMakeAnnular ? 1 : 0
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
    }
}

extension SDFShader: AdjustableComputeShaderDefinition {
    func makeAdjustmentView(definition: Binding<any IsComputeShaderDefinition>) -> AnyView {
        let typedBinding = Binding<SDFShader>(
            get: { definition.wrappedValue as! SDFShader },
            set: { definition.wrappedValue = $0 }
        )
        return AnyView(SDFShaderAdjustmentView(shader: typedBinding))
    }
}

struct SDFShaderAdjustmentView: View {
    @Binding var shader: SDFShader
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                HStack(spacing: 24) {
                    HStack {
                        Text("SDF Function")
                        Picker("", selection: $shader.selectedShape) {
                            ForEach(SDFShape.allCases, id: \.self) { shape in
                                Text(shape.displayName).tag(shape)
                            }
                        }
                        .pickerStyle(.menu)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Toggle("Enable Masking", isOn: $shader.shouldMask)
                            .frame(width: 200)
                    }
                }
                
                HStack {
                    Text("Scale: ")
                    Slider(value: $shader.scale, in: 0...1, step: 0.01)
                }
                
                HStack {
                    Text("Intensity: ")
                    Slider(value: $shader.intensity, in: 0...1, step: 0.01)
                }
                
                HStack(spacing: 24) {
                    HStack {
                        Text("Repetitions: ")
                        Slider(value: $shader.repetitions, in: 1...20, step: 1)
                        Text("\(Int(shader.repetitions))")
                    }
                    
                    Toggle("Flip Alternating", isOn: $shader.shouldFlipAlternating)
                        .frame(width: 175)
                }
                
                HStack {
                    Text("Blend Amount: ")
                    Slider(value: $shader.blendK, in: 0...1.0, step: 0.01)
                    Text(String(format: "%.2f", shader.blendK))
                }

                HStack(spacing: 24) {
                    Toggle("Make Annular (Ring)", isOn: $shader.shouldMakeAnnular)
                        .frame(width: 225)
                    Spacer()
                    
                    if shader.shouldMakeAnnular {
                        HStack {
                            Text("Shell Thickness: ")
                            Slider(value: $shader.shellThickness, in: 0...1, step: 0.01)
                            Text(String(format: "%.2f", shader.shellThickness))
                        }
                    }
                }

                HStack(spacing: 24) {
                    Toggle("Auto Rotate", isOn: $shader.isRotating)
                        .frame(width: 150)
                    Spacer()
                    
                    if shader.isRotating {
                        Text("Speed: ")
                        Slider(value: $shader.rotationSpeed, in: 0...3, step: 0.025)
                        Text(String(format: "%.1f", shader.rotationSpeed))
                    } else {
                        Text("Rotation: ")
                        Slider(value: $shader.rotation,
                               in: 0...(2 * Float.pi),  // Full 360 degree rotation
                               step: 0.01)
                        Text("\(Int(shader.rotation * 180 / Float.pi))°") // Show in degrees
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 425)
    }
}

struct SDFMetalView: View {
    @State var stateManager = ComputeShaderStateManager(shaderDefinition: SDFShader())
    
    var body: some View {
        VStack {
            MetalShaderProtocolView(stateManager: stateManager)
                .aspectRatio(1.0, contentMode: .fit)
            
            if let adjustableDefinition = stateManager.shaderDefinition as? AdjustableComputeShaderDefinition {
                adjustableDefinition.makeAdjustmentView(definition: $stateManager.shaderDefinition)
                    .padding()
            }
        }
    }
}

#Preview {
    SDFMetalView()
}
