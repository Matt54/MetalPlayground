//
//  ShapingFunctionsMetalView.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/22/25.
//

import SwiftUI

struct ShapingFunctionsMetalView: View {
    @State var stateManager = ComputeShaderStateManager(shaderDefinition: ExponentialShader())
    
    var body: some View {
        let shaderType = Binding<ShaderType>(
            get: {
                if stateManager.shaderDefinition is LinearInterpolationShader {
                    return .linearInterpolation
                } else if stateManager.shaderDefinition is ExponentialShader {
                    return .exponentialFunction
                } else if stateManager.shaderDefinition is StepShader {
                    return .stepFunction
                } else if stateManager.shaderDefinition is SmoothStepShader {
                    return .smoothStepFunction
                } else if stateManager.shaderDefinition is LogShader {
                    return .logFunction
                } else if stateManager.shaderDefinition is SqrtShader {
                    return .sqrtFunction
                } else if stateManager.shaderDefinition is ExpImpulseShader {
                    return .expImpulseFunction
                } else if stateManager.shaderDefinition is SincShader {
                    return .sincFunction
                } else if stateManager.shaderDefinition is CubicPulseShader {
                    return .cubicPulseFunction
                }
                return .linearInterpolation
            },
            set: {
                switch $0 {
                case .linearInterpolation:
                    stateManager.shaderDefinition = LinearInterpolationShader()
                case .exponentialFunction:
                    stateManager.shaderDefinition = ExponentialShader()
                case .stepFunction:
                    stateManager.shaderDefinition = StepShader()
                case .smoothStepFunction:
                    stateManager.shaderDefinition = SmoothStepShader()
                case .logFunction:
                    stateManager.shaderDefinition = LogShader()
                case .sqrtFunction:
                    stateManager.shaderDefinition = SqrtShader()
                case .expImpulseFunction:
                    stateManager.shaderDefinition = ExpImpulseShader()
                case .sincFunction:
                    stateManager.shaderDefinition = SincShader()
                case .cubicPulseFunction:
                    stateManager.shaderDefinition = CubicPulseShader()
                }
            }
        )
        
        VStack {
            MetalShaderProtocolView(stateManager: stateManager)
                .aspectRatio(contentMode: .fit)
            
            VStack(spacing: 36) {
                HStack {
                    Text("Shaping Function: ")
                    Spacer()
                    Picker("", selection: shaderType) {
                        ForEach(ShaderType.allCases, id: \.self) { shader in
                            Text(shader.displayName).tag(shader)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .padding()
                
                if let adjustableDefinition = stateManager.shaderDefinition as? AdjustableComputeShaderDefinition {
                    ScrollView {
                        adjustableDefinition.makeAdjustmentView(definition: $stateManager.shaderDefinition)
                            .padding()
                    }
                    
                    .frame(height: 200)
                }
            }
            
            Spacer()
        }
    }
    
    enum ShaderType: CaseIterable {
        case linearInterpolation
        case exponentialFunction
        case stepFunction
        case smoothStepFunction
        case logFunction
        case sqrtFunction
        case expImpulseFunction
        case sincFunction
        case cubicPulseFunction
        
        var displayName: String {
            switch self {
            case .linearInterpolation:
                return "lerp"
            case .exponentialFunction:
                return "expo"
            case .stepFunction:
                return "step"
            case .smoothStepFunction:
                return "smooth"
            case .logFunction:
                return "log"
            case .sqrtFunction:
                return "sqrt"
            case .expImpulseFunction:
                return "expImpulse"
            case .sincFunction:
                return "sinc"
            case .cubicPulseFunction:
                return "cubicPulse"
            }
        }
    }
}

extension ExponentialShader: AdjustableComputeShaderDefinition {
    func makeAdjustmentView(definition: Binding<any IsComputeShaderDefinition>) -> AnyView {
        let typedBinding = Binding<ExponentialShader>(
            get: { definition.wrappedValue as! ExponentialShader },
            set: { definition.wrappedValue = $0 }
        )
        return AnyView(ExponentialFunctionAdjustmentView(shader: typedBinding))
    }
}

struct ExponentialFunctionAdjustmentView: View {
    @Binding var shader: ExponentialShader
    var body: some View {
        VStack {
            Text("Exponent: \(shader.exponent)")
            Slider(value: $shader.exponent, in: 0...20.0)
        }
    }
}

#Preview {
    ShapingFunctionsMetalView()
}

struct LinearInterpolationShader: IsComputeShaderDefinition, Codable {
    var functionName: String = "linearInterpolation"
}

struct ExponentialShader: IsComputeShaderDefinitionWithParameters, Codable {
    var functionName: String = "exponentialFunction"
    var setByteLength: Int = MemoryLayout<ExponentialFunctionParams>.stride
    var exponent: Float = 5.0
    
    func withParameters<T>(_ properties: [String : Any], _ body: (UnsafeRawPointer) -> T) -> T {
        var params = ExponentialFunctionParams(exponent: exponent)
        return withUnsafePointer(to: &params) {
            body(UnsafeRawPointer($0))
        }
    }
    
    func updateRuntimeProperties(_ properties: inout [String : Any], deltaTime: Double) { }
}

struct StepShader: IsComputeShaderDefinitionWithParameters, Codable {
    var functionName: String = "stepFunction"
    var setByteLength: Int = MemoryLayout<StepFunctionParams>.stride
    var threshold: Float = 0.5
    
    func withParameters<T>(_ properties: [String : Any], _ body: (UnsafeRawPointer) -> T) -> T {
        var params = StepFunctionParams(threshold: threshold)
        return withUnsafePointer(to: &params) {
            body(UnsafeRawPointer($0))
        }
    }
    
    func updateRuntimeProperties(_ properties: inout [String : Any], deltaTime: Double) { }
}

struct SmoothStepShader: IsComputeShaderDefinitionWithParameters, Codable {
    var functionName: String = "smoothStepFunction"
    var setByteLength: Int = MemoryLayout<SmoothStepFunctionParams>.stride
    var edge0: Float = 0.1
    var edge1: Float = 0.9
    
    func withParameters<T>(_ properties: [String : Any], _ body: (UnsafeRawPointer) -> T) -> T {
        var params = SmoothStepFunctionParams(edge0: edge0, edge1: edge1)
        return withUnsafePointer(to: &params) {
            body(UnsafeRawPointer($0))
        }
    }
    
    func updateRuntimeProperties(_ properties: inout [String : Any], deltaTime: Double) { }
}

extension StepShader: AdjustableComputeShaderDefinition {
    func makeAdjustmentView(definition: Binding<any IsComputeShaderDefinition>) -> AnyView {
        let typedBinding = Binding<StepShader>(
            get: { definition.wrappedValue as! StepShader },
            set: { definition.wrappedValue = $0 }
        )
        return AnyView(StepFunctionAdjustmentView(shader: typedBinding))
    }
}

extension SmoothStepShader: AdjustableComputeShaderDefinition {
    func makeAdjustmentView(definition: Binding<any IsComputeShaderDefinition>) -> AnyView {
        let typedBinding = Binding<SmoothStepShader>(
            get: { definition.wrappedValue as! SmoothStepShader },
            set: { definition.wrappedValue = $0 }
        )
        return AnyView(SmoothStepFunctionAdjustmentView(shader: typedBinding))
    }
}

struct StepFunctionAdjustmentView: View {
    @Binding var shader: StepShader
    var body: some View {
        VStack {
            Text("Threshold: \(shader.threshold)")
            Slider(value: $shader.threshold, in: 0...1.0)
        }
    }
}

struct SmoothStepFunctionAdjustmentView: View {
    @Binding var shader: SmoothStepShader
    var body: some View {
        VStack {
            Text("Edge 0: \(shader.edge0)")
            Slider(value: $shader.edge0, in: 0...1.0)
            
            Text("Edge 1: \(shader.edge1)")
            Slider(value: $shader.edge1, in: 0...1.0)
        }
    }
}

struct LogShader: IsComputeShaderDefinitionWithParameters, Codable {
    var functionName: String = "logFunction"
    var setByteLength: Int = MemoryLayout<LogFunctionParams>.stride
    var base: Float = 0.1
    var offset: Float = 0.1
    
    func withParameters<T>(_ properties: [String : Any], _ body: (UnsafeRawPointer) -> T) -> T {
        var params = LogFunctionParams(base: base, offset: offset)
        return withUnsafePointer(to: &params) {
            body(UnsafeRawPointer($0))
        }
    }
    
    func updateRuntimeProperties(_ properties: inout [String : Any], deltaTime: Double) { }
}

struct SqrtShader: IsComputeShaderDefinitionWithParameters, Codable {
    var functionName: String = "sqrtFunction"
    var setByteLength: Int = MemoryLayout<SqrtFunctionParams>.stride
    var scale: Float = 1.0
    
    func withParameters<T>(_ properties: [String : Any], _ body: (UnsafeRawPointer) -> T) -> T {
        var params = SqrtFunctionParams(scale: scale)
        return withUnsafePointer(to: &params) {
            body(UnsafeRawPointer($0))
        }
    }
    
    func updateRuntimeProperties(_ properties: inout [String : Any], deltaTime: Double) { }
}

extension LogShader: AdjustableComputeShaderDefinition {
    func makeAdjustmentView(definition: Binding<any IsComputeShaderDefinition>) -> AnyView {
        let typedBinding = Binding<LogShader>(
            get: { definition.wrappedValue as! LogShader },
            set: { definition.wrappedValue = $0 }
        )
        return AnyView(LogFunctionAdjustmentView(shader: typedBinding))
    }
}

extension SqrtShader: AdjustableComputeShaderDefinition {
    func makeAdjustmentView(definition: Binding<any IsComputeShaderDefinition>) -> AnyView {
        let typedBinding = Binding<SqrtShader>(
            get: { definition.wrappedValue as! SqrtShader },
            set: { definition.wrappedValue = $0 }
        )
        return AnyView(SqrtFunctionAdjustmentView(shader: typedBinding))
    }
}

struct LogFunctionAdjustmentView: View {
    @Binding var shader: LogShader
    var body: some View {
        VStack {
            Text("Base: \(shader.base)")
            Slider(value: $shader.base, in: 0.1...0.9999)
            
            Text("Offset: \(shader.offset)")
            Slider(value: $shader.offset, in: 0.001...0.1)
        }
    }
}

struct SqrtFunctionAdjustmentView: View {
    @Binding var shader: SqrtShader
    var body: some View {
        VStack {
            Text("Scale: \(shader.scale)")
            Slider(value: $shader.scale, in: 0.1...10.0)
        }
    }
}

struct ExpImpulseShader: IsComputeShaderDefinitionWithParameters, Codable {
    var functionName: String = "expImpulseFunction"
    var setByteLength: Int = MemoryLayout<ExpImpulseParams>.stride
    var k: Float = 5.0
    
    func withParameters<T>(_ properties: [String : Any], _ body: (UnsafeRawPointer) -> T) -> T {
        var params = ExpImpulseParams(k: k)
        return withUnsafePointer(to: &params) {
            body(UnsafeRawPointer($0))
        }
    }
    
    func updateRuntimeProperties(_ properties: inout [String : Any], deltaTime: Double) { }
}

extension ExpImpulseShader: AdjustableComputeShaderDefinition {
    func makeAdjustmentView(definition: Binding<any IsComputeShaderDefinition>) -> AnyView {
        let typedBinding = Binding<ExpImpulseShader>(
            get: { definition.wrappedValue as! ExpImpulseShader },
            set: { definition.wrappedValue = $0 }
        )
        return AnyView(ExpImpulseFunctionAdjustmentView(shader: typedBinding))
    }
}

struct ExpImpulseFunctionAdjustmentView: View {
    @Binding var shader: ExpImpulseShader
    var body: some View {
        VStack {
            Text("k: \(shader.k)")
            Slider(value: $shader.k, in: 0.1...20.0)
        }
    }
}

struct SincShader: IsComputeShaderDefinitionWithParameters, Codable {
    var functionName: String = "sincFunction"
    var setByteLength: Int = MemoryLayout<SincFunctionParams>.stride
    var k: Float = 10.0
    var addition: Float = 0.25
    
    func withParameters<T>(_ properties: [String : Any], _ body: (UnsafeRawPointer) -> T) -> T {
        var params = SincFunctionParams(k: k, addition: addition)
        return withUnsafePointer(to: &params) {
            body(UnsafeRawPointer($0))
        }
    }
    
    func updateRuntimeProperties(_ properties: inout [String : Any], deltaTime: Double) { }
}

extension SincShader: AdjustableComputeShaderDefinition {
    func makeAdjustmentView(definition: Binding<any IsComputeShaderDefinition>) -> AnyView {
        let typedBinding = Binding<SincShader>(
            get: { definition.wrappedValue as! SincShader },
            set: { definition.wrappedValue = $0 }
        )
        return AnyView(SincFunctionAdjustmentView(shader: typedBinding))
    }
}

struct SincFunctionAdjustmentView: View {
    @Binding var shader: SincShader
    var body: some View {
        VStack {
            Text("k: \(shader.k)")
            Slider(value: $shader.k, in: 0.1...20.0)
            
            Text("Addition: \(shader.addition)")
            Slider(value: $shader.addition, in: -1.0...1.0)
        }
    }
}

struct CubicPulseShader: IsComputeShaderDefinitionWithParameters, Codable {
    var functionName: String = "cubicPulseFunction"
    var setByteLength: Int = MemoryLayout<CubicPulseParams>.stride
    var center: Float = 0.5
    var width: Float = 0.2
    
    func withParameters<T>(_ properties: [String : Any], _ body: (UnsafeRawPointer) -> T) -> T {
        var params = CubicPulseParams(center: center, width: width)
        return withUnsafePointer(to: &params) {
            body(UnsafeRawPointer($0))
        }
    }
    
    func updateRuntimeProperties(_ properties: inout [String : Any], deltaTime: Double) { }
}

extension CubicPulseShader: AdjustableComputeShaderDefinition {
    func makeAdjustmentView(definition: Binding<any IsComputeShaderDefinition>) -> AnyView {
        let typedBinding = Binding<CubicPulseShader>(
            get: { definition.wrappedValue as! CubicPulseShader },
            set: { definition.wrappedValue = $0 }
        )
        return AnyView(CubicPulseFunctionAdjustmentView(shader: typedBinding))
    }
}

struct CubicPulseFunctionAdjustmentView: View {
    @Binding var shader: CubicPulseShader
    var body: some View {
        VStack {
            Text("Center: \(shader.center)")
            Slider(value: $shader.center, in: 0.0...1.0)
            
            Text("Width: \(shader.width)")
            Slider(value: $shader.width, in: 0.01...0.5)
        }
    }
}
