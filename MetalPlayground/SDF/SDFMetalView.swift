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
    case star = 9
    
    var metalShape: SDFPrimitive {
        SDFPrimitive(rawValue: UInt32(self.rawValue))
    }
    
    var metalValue: Int32 {
        Int32(rawValue)
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
        case .star: return "Star"
        }
    }
    
    var description: String {
        switch self {
        case .circle: return "A perfect circle"
        case .box: return "A rectangular shape"
        case .triangle: return "An equilateral triangle"
        case .roundedBox: return "A rectangle with rounded corners"
        case .regularPolygon: return "A regular hexagon"
        case .line: return "A diagonal line with thickness"
        case .capsule: return "A line with rounded ends"
        case .ellipse: return "A stretched circle"
        case .cross: return "Two intersecting rectangles"
        case .star: return "A five-pointed star"
        }
    }
}

struct SDFShader: IsComputeShaderDefinitionWithParameters {
    var functionName: String = "sdfDrawing"
    var setByteLength: Int = MemoryLayout<SDFParams>.stride
    var shouldMask: Bool = false
    var selectedShape: SDFShape = .circle
    var intensity: Float = 1.0

    func withParameters<T>(_ properties: [String: Any], _ body: (UnsafeRawPointer) -> T) -> T {
        var params = SDFParams(
            shouldMask: shouldMask ? 1 : 0,
            shape: selectedShape.metalShape,
            intensity: intensity
        )
        return withUnsafePointer(to: &params) {
            body(UnsafeRawPointer($0))
        }
    }
    
    func updateRuntimeProperties(_ properties: inout [String: Any], deltaTime: Double) { }
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
        VStack(spacing: 24) {
            HStack {
                Text("SDF Function")
                Spacer()
                Picker("", selection: $shader.selectedShape) {
                    ForEach(SDFShape.allCases, id: \.self) { shape in
                        Text(shape.displayName).tag(shape)
                    }
                }
                .pickerStyle(.menu)
            }
            
            Toggle("Enable Masking", isOn: $shader.shouldMask)
            
            HStack {
                Text("Intensity: ")
                Slider(value: $shader.intensity, in: 0...1, step: 0.01)
            }
                
        }
        .padding(.horizontal)
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
