//
//  MetalShaderProtocolView.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/6/25.
//

import MetalKit
import SwiftUI

struct MetalShaderProtocolView: View {
    let stateManager: ComputeShaderStateManager
    
    private func createView(context: ViewRepresentableContext<MetalShaderProtocolView>) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = true
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        mtkView.framebufferOnly = false
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        mtkView.drawableSize = mtkView.frame.size
        mtkView.enableSetNeedsDisplay = true
        mtkView.isPaused = false
        return mtkView
    }
    
    private func updateView(_ mtkView: MTKView, context: ViewRepresentableContext<MetalShaderProtocolView>) {
        // Update the compute pipeline when shader type changes
        let updateFunction = context.coordinator.library.makeFunction(name: stateManager.shaderDefinition.functionName)!
        context.coordinator.computePipeline = try! context.coordinator.device.makeComputePipelineState(function: updateFunction)
        context.coordinator.stateManager = stateManager
    }
    
    class Coordinator : NSObject, MTKViewDelegate {
        var parent: MetalShaderProtocolView
        var device: MTLDevice!
        var commandQueue: MTLCommandQueue!
        var computePipeline: MTLComputePipelineState!
        let library: MTLLibrary
        var stateManager: ComputeShaderStateManager
        
        init(_ parent: MetalShaderProtocolView) {
            self.parent = parent
            if let device = MTLCreateSystemDefaultDevice() {
                self.device = device
            }
            self.commandQueue = device.makeCommandQueue()!
            
            self.library = device.makeDefaultLibrary()!
            
            let updateFunction = library.makeFunction(name: parent.stateManager.shaderDefinition.functionName)!
            self.computePipeline = try! device.makeComputePipelineState(function: updateFunction)
            
            stateManager = parent.stateManager
            
            super.init()
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }
        
        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable else {
                return
            }
            
            guard let commandBuffer = commandQueue.makeCommandBuffer(),
                  let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
                return
            }
            
            // Set the compute pipeline state
            computeEncoder.setComputePipelineState(computePipeline)
            
            // Get the output texture from the drawable
            let outTexture = drawable.texture
            
            // Set the output texture
            computeEncoder.setTexture(outTexture, index: 0)

            stateManager.updateProperties()
            stateManager.shaderDefinition.withParameters(stateManager.runtimeProperties) { ptr in
                computeEncoder.setBytes(ptr, length: stateManager.shaderDefinition.setByteLength, index: 0)
            }
            
            // Calculate threadgroup sizes
            let w = computePipeline.threadExecutionWidth
            let h = computePipeline.maxTotalThreadsPerThreadgroup / w
            let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
            
            // Calculate threadgroups based on texture size
            let threadgroupsX = (outTexture.width + w - 1) / w
            let threadgroupsY = (outTexture.height + h - 1) / h
            let threadgroups = MTLSizeMake(threadgroupsX, threadgroupsY, 1)
            
            // Dispatch the compute shader
            computeEncoder.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadsPerThreadgroup)
            
            // End encoding and commit
            computeEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}

extension MetalShaderProtocolView: ViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    #if os(macOS)
    func makeNSView(context: ViewRepresentableContext<MetalShaderProtocolView>) -> MTKView {
        createView(context: context)
    }
    
    func updateNSView(_ nsView: MTKView, context: ViewRepresentableContext<MetalShaderProtocolView>) {
        updateView(nsView, context: context)
    }
    #else
    func makeUIView(context: ViewRepresentableContext<MetalShaderProtocolView>) -> MTKView {
        createView(context: context)
    }
    
    func updateUIView(_ uiView: MTKView, context: ViewRepresentableContext<MetalShaderProtocolView>) {
        updateView(uiView, context: context)
    }
    #endif
}
