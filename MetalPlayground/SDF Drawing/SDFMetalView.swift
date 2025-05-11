//
//  SDFMetalView.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 5/4/25.
//

import SwiftUI

enum SDFShape: Int, CaseIterable, Codable {
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
    @State private var showingSaveDialog = false
    @State private var newPresetName = ""
    @State private var savedPresets: [String: SDFShader] = [:]
    @State private var currentPresetName: String = "Default"

    private var sdfFunctionPickerView: some View {
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
    }

    private var enableMaskingToggleView: some View {
        Toggle("Enable Masking", isOn: $shader.shouldMask)
            .frame(width: 200)
    }
    
    private var repetitionsView: some View {
        HStack {
            Text("Tile Repeats: ")
            Slider(value: $shader.repetitions, in: 1...20, step: 1)
            Text("\(Int(shader.repetitions))")
        }
        .frame(minWidth: 300)
    }
    
    private var flipAlternativeToggleView: some View {
        Toggle("Flip Alternating", isOn: $shader.shouldFlipAlternating)
            .frame(width: 175)
    }
    
    private var annualRingToggleView: some View {
        Toggle("Annular (Ring)", isOn: $shader.shouldMakeAnnular)
            .frame(width: 175)
    }
    
    private var shellThicknessView: some View {
        HStack {
            Text("Shell Thickness: ")
            Slider(value: $shader.shellThickness, in: 0...1, step: 0.01)
            Text(String(format: "%.2f", shader.shellThickness))
        }
        .frame(minWidth: 300)
    }
    
    private var autoRotateToggleView: some View {
        Toggle("Auto Rotate", isOn: $shader.isRotating)
            .frame(width: 150)
    }
    
    private var rotationView: some View {
        HStack {
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
        .frame(minWidth: 300)
    }
    
    private var applyPatternToggleView: some View {
        Toggle("Pattern Repeats", isOn: $shader.shouldApplyPattern)
            .frame(width: 200)
    }
    
    private var patternFrequencyView: some View {
        HStack {
            Text("Pattern Frequency: ")
            Slider(value: $shader.patternFrequency, in: 1...20, step: 0.5)
            Text(String(format: "%.1f", shader.patternFrequency))
        }
        .frame(minWidth: 300)
    }

    private var patternAnimationToggleView: some View {
        Toggle("Pattern Animation", isOn: $shader.isPatternAnimated)
            .frame(width: 200)
    }

    private var patternAnimationSpeedView: some View {
        HStack {
            if shader.isPatternAnimated {
                Text("Speed: ")
                Slider(value: $shader.patternAnimationSpeed, in: 0...3, step: 0.025)
                Text(String(format: "%.1f", shader.patternAnimationSpeed))
            } else {
                Text("Phase: ")
                Slider(value: $shader.patternPhase,
                       in: 0...(2 * Float.pi),  // Full 360 degree
                       step: 0.01)
                Text("\(Int(shader.patternPhase * 180 / Float.pi))°") // Show in degrees
            }
        }
        .frame(minWidth: 300)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack(spacing: 16) {
                    Spacer()
                    Menu {
                        ForEach(Array(savedPresets.keys), id: \.self) { presetName in
                            Button(presetName) {
                                shader = savedPresets[presetName]!
                                currentPresetName = presetName
                            }
                        }
                    } label: {
                        Label(currentPresetName, systemImage: "folder")
                            .frame(width: 120)
                    }
                    .disabled(savedPresets.isEmpty)
                    
                    Spacer()
                    
                    Button {
                        showingSaveDialog = true
                    } label: {
                        Label("Save Preset", systemImage: "square.and.arrow.down")
                            .frame(width: 120)
                    }
                    Spacer()
                }
                    .padding(.vertical, 8)
                
                ViewThatFits {
                    HStack(spacing: 24) {
                        sdfFunctionPickerView
                        HStack {
                            Spacer()
                            enableMaskingToggleView
                        }
                    }
                    VStack(alignment: .leading, spacing: 24) {
                        sdfFunctionPickerView
                        HStack {
                            enableMaskingToggleView
                            Spacer()
                        }
                    }
                }
                
                HStack {
                    Text("Scale: ")
                    Slider(value: $shader.scale, in: 0...1, step: 0.01)
                    Text(String(format: "%.2f", shader.scale))
                }
                
                ViewThatFits {
                    HStack(spacing: 24) {
                        annualRingToggleView
                        Spacer()
                        if shader.shouldMakeAnnular {
                            shellThicknessView
                        }
                    }
                    VStack(alignment: .leading, spacing: 24) {
                        annualRingToggleView
                        if shader.shouldMakeAnnular {
                            shellThicknessView
                        }
                    }
                }
                
                HStack {
                    Text("Intensity: ")
                    Slider(value: $shader.intensity, in: 0...1, step: 0.01)
                    Text(String(format: "%.2f", shader.intensity))
                }

                HStack {
                    Text("Contrast: ")
                    Slider(value: $shader.contrast, in: 0...10, step: 0.01)
                    Text(String(format: "%.2f", shader.contrast))
                }
                
                ViewThatFits {
                    HStack(spacing: 24) {
                        repetitionsView
                        flipAlternativeToggleView
                    }
                    VStack(alignment: .leading, spacing: 24) {
                        repetitionsView
                        HStack {
                            flipAlternativeToggleView
                            Spacer()
                        }
                    }
                }
                
                HStack {
                    Text("Blend Amount: ")
                    Slider(value: $shader.blendK, in: 0...1.0, step: 0.01)
                    Text(String(format: "%.2f", shader.blendK))
                }

                ViewThatFits {
                    HStack(spacing: 24) {
                        autoRotateToggleView
                        Spacer()
                        rotationView
                    }
                    
                    VStack(alignment: .leading, spacing: 24) {
                        autoRotateToggleView
                        rotationView
                    }
                }
                
                ViewThatFits {
                    HStack(spacing: 24) {
                        applyPatternToggleView
                        Spacer()
                        if shader.shouldApplyPattern {
                            patternFrequencyView
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 24) {
                        applyPatternToggleView
                        if shader.shouldApplyPattern {
                            patternFrequencyView
                        }
                    }
                }

                ViewThatFits {
                    HStack(spacing: 24) {
                        patternAnimationToggleView
                        Spacer()
                        patternAnimationSpeedView
                    }
                    VStack(alignment: .leading, spacing: 24) {
                        patternAnimationToggleView
                        patternAnimationSpeedView
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 425)
        .alert("Save Preset", isPresented: $showingSaveDialog) {
            TextField("Preset Name", text: $newPresetName)
            Button("Save") {
                if !newPresetName.isEmpty {
                    savedPresets[newPresetName] = shader
                    savePresets()
                    newPresetName = ""
                }
            }
            Button("Cancel", role: .cancel) {
                newPresetName = ""
            }
        } message: {
            Text("Enter a name for your shader preset")
        }
        .onAppear {
            loadPresets()
        }
    }
    
    private func savePresets() {
        if let encoded = try? JSONEncoder().encode(savedPresets) {
            UserDefaults.standard.set(encoded, forKey: "SDFShaderPresets")
        }
    }
    
    private func loadPresets() {
        if let data = UserDefaults.standard.data(forKey: "SDFShaderPresets"),
           let decoded = try? JSONDecoder().decode([String: SDFShader].self, from: data) {
            savedPresets = decoded
        }
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

