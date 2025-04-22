//
//  StaticMetalView.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/17/25.
//

import Foundation
import MetalKit
import SwiftUI

struct StaticMetalView {
    var functionName: String
    init(functionName: String = "helloWorld") {
        self.functionName = functionName
    }
    
    private func createView(context: ViewRepresentableContext<StaticMetalView>) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        mtkView.framebufferOnly = false
        return mtkView
    }
    
    private func updateView(_ mtkView: MTKView, context: ViewRepresentableContext<StaticMetalView>) {
        // You can handle updates here if needed
    }
    
    class Coordinator : NSObject, MTKViewDelegate {
        var parent: StaticMetalView
        var device: MTLDevice!
        var commandQueue: MTLCommandQueue!
        var computePipeline: MTLComputePipelineState!
        let library: MTLLibrary
        
        // reference time used when calculating current time for shader
        var startTime = Date()
        
        init(_ parent: StaticMetalView) {
            self.parent = parent
            if let device = MTLCreateSystemDefaultDevice() {
                self.device = device
            }
            self.commandQueue = device.makeCommandQueue()!
            
            self.library = device.makeDefaultLibrary()!
            
            let updateFunction = library.makeFunction(name: parent.functionName)!
            self.computePipeline = try! device.makeComputePipelineState(function: updateFunction)
            
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
            
            // Feed in any parameters you need in the shader (using just time here)
            let currentTime = Date().timeIntervalSince(startTime)
            var params = ExampleShaderParams(time: Float(currentTime))
            computeEncoder.setBytes(&params, length: MemoryLayout<ExampleShaderParams>.size, index: 0)
            
            // Calculate thread group sizes
            let w = computePipeline.threadExecutionWidth
            let h = computePipeline.maxTotalThreadsPerThreadgroup / w
            let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
            
            // Calculate thread groups based on texture size
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

extension StaticMetalView: ViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    #if os(macOS)
    func makeNSView(context: ViewRepresentableContext<StaticMetalView>) -> MTKView {
        createView(context: context)
    }
    
    func updateNSView(_ nsView: MTKView, context: ViewRepresentableContext<StaticMetalView>) {
        updateView(nsView, context: context)
    }
    #else
    func makeUIView(context: ViewRepresentableContext<StaticMetalView>) -> MTKView {
        createView(context: context)
    }
    
    func updateUIView(_ uiView: MTKView, context: ViewRepresentableContext<StaticMetalView>) {
        updateView(uiView, context: context)
    }
    #endif
}

#Preview {
    StaticMetalView()
}
