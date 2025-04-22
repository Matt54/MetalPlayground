//
//  HelloWorldMetalView.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/17/25.
//

import SwiftUI

struct HelloWorldMetalView: View {
    var body: some View {
        StaticMetalView(functionName: "helloWorld")
    }
}

#Preview {
    HelloWorldMetalView()
}
