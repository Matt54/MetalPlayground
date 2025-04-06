//
//  ShaderProtocolAdjustmentView.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/6/25.
//

import SwiftUI

struct ShaderProtocolAdjustmentView: View {
    @State var stateManager: ComputeShaderStateManager = ComputeShaderStateManager()
    
    let options: [ShaderType] = [.example1, .example2, .distanceField]
    
    var body: some View {
        let shaderType = Binding<ShaderType>(
            get: {
                if stateManager.shaderDefinition is ExampleShader1 {
                    .example1
                } else if stateManager.shaderDefinition is ExampleShader2 {
                    .example2
                } else {
                    .distanceField
                }
            },
            set: {
                switch $0 {
                case .example1:
                    stateManager.shaderDefinition = ExampleShader1()
                case .example2:
                    stateManager.shaderDefinition = ExampleShader2()
                case .distanceField:
                    stateManager.shaderDefinition = DistanceFieldShader()
                }
            }
        )
        
        VStack {
            MetalShaderProtocolView(stateManager: stateManager)

            Picker("Shader Type", selection: shaderType) {
                ForEach(options, id: \.self) { shader in
                    Text(shader.displayName).tag(shader)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if let adjustableDefinition = stateManager.shaderDefinition as? AdjustableComputeShaderDefinition {
                ScrollView {
                    adjustableDefinition.makeAdjustmentView(definition: $stateManager.shaderDefinition)
                }
                .frame(height: 200)
            }
        }
    }
    
    enum ShaderType: CaseIterable, Codable {
        case example1
        case example2
        case distanceField
        
        var displayName: String {
            switch self {
            case .example1:
                return "example 1"
            case .example2:
                return "example 2"
            case .distanceField:
                return "Distance Field"
            }
        }
    }
}

#Preview {
    ShaderProtocolAdjustmentView()
}

// This is just a convenient way to organize the adjustment views (sliders and such)
protocol AdjustableComputeShaderDefinition: IsComputeShaderDefinition {
    func makeAdjustmentView(definition: Binding<any IsComputeShaderDefinition>) -> AnyView
}

extension ExampleShader1: AdjustableComputeShaderDefinition {
    func makeAdjustmentView(definition: Binding<any IsComputeShaderDefinition>) -> AnyView {
        let typedBinding = Binding<ExampleShader1>(
            get: { definition.wrappedValue as! ExampleShader1 },
            set: { definition.wrappedValue = $0 }
        )
        return AnyView(ExampleShader1AdjustmentView(shader: typedBinding))
    }
}

struct ExampleShader1AdjustmentView: View {
    @Binding var shader: ExampleShader1
    
    var body: some View {
        VStack {
            Text("animationRate: \(shader.animationRate, specifier: "%.2f")")
            Slider(value: $shader.animationRate, in: 0...2.0)
                .padding(.horizontal)
        }
        
        VStack {
            Text("hueRotateRate: \(shader.hueRotateRate, specifier: "%.2f")")
            Slider(value: $shader.hueRotateRate, in: 0...2.0)
                .padding(.horizontal)
        }
    }
}

extension ExampleShader2: AdjustableComputeShaderDefinition {
    func makeAdjustmentView(definition: Binding<any IsComputeShaderDefinition>) -> AnyView {
        let typedBinding = Binding<ExampleShader2>(
            get: { definition.wrappedValue as! ExampleShader2 },
            set: { definition.wrappedValue = $0 }
        )
        return AnyView(ExampleShader2AdjustmentView(shader: typedBinding))
    }
}

struct ExampleShader2AdjustmentView: View {
    @Binding var shader: ExampleShader2
    
    var body: some View {
        Toggle(isOn: $shader.isBox, label: {
            Text("is box: \(shader.isBox)")
        })
        .padding(.horizontal)
        
        VStack {
            Text("animationRate: \(shader.animationRate, specifier: "%.2f")")
            Slider(value: $shader.animationRate, in: 0...2.0)
                .padding(.horizontal)
        }
        
        VStack {
            Text("hueRotateRate: \(shader.hueRotateRate, specifier: "%.2f")")
            Slider(value: $shader.hueRotateRate, in: 0...2.0)
                .padding(.horizontal)
        }
    }
}

extension DistanceFieldShader: AdjustableComputeShaderDefinition {
    func makeAdjustmentView(definition: Binding<any IsComputeShaderDefinition>) -> AnyView {
        let typedBinding = Binding<DistanceFieldShader>(
            get: { definition.wrappedValue as! DistanceFieldShader },
            set: { definition.wrappedValue = $0 }
        )
        return AnyView(DistanceFieldAdjustmentView(shader: typedBinding))
    }
}

struct DistanceFieldAdjustmentView: View {
    @Binding var shader: DistanceFieldShader
    
    var body: some View {
        VStack {
            Text("width: \(shader.width, specifier: "%.2f")")
            Slider(value: $shader.width, in: 0.1...0.5)
                .padding(.horizontal)
        }
    }
}
