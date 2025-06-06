//
//  MainNavigationView.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/17/25.
//

import SwiftUI

struct MainNavigationView: View {
    @State private var columnVisibility = NavigationSplitViewVisibility.automatic
    @State private var selectedRoute: NavigationRoute?
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selectedRoute) {
                Section("Simple Examples") {
                    ForEach(NavigationRoute.simpleExamples) { route in
                        NavigationLink(value: route) {
                            Text(route.title)
                                .tag(route)
                        }
                    }
                }
                
                Section("SDF Drawing") {
                    ForEach(NavigationRoute.sdfDrawingExamples) { route in
                        NavigationLink(value: route) {
                            Text(route.title)
                                .tag(route)
                        }
                    }
                }
                
                Section("Book of Shaders Examples") {
                    ForEach(NavigationRoute.bookOfShadersExamples) { route in
                        NavigationLink(value: route) {
                            Text(route.title)
                                .tag(route)
                        }
                    }
                }
            }
            .navigationTitle("Metal Playground")
        } detail: {
            if let route = selectedRoute {
                switch route {
                case .example1:
                    MetalView()
                case .example2:
                    ShaderProtocolAdjustmentView()
                case .helloWorld:
                    HelloWorldMetalView()
                case .colorPicker:
                    ColorPickerMetalView()
                case .sineTransition:
                    SineTransitionView()
                case .shapingFunctions:
                    ShapingFunctionsMetalView()
                case .colorGradient:
                    ColorGradientMetalView()
                case .polarGradient:
                    PolarColorGradientView()
                case .sdfDrawing:
                    SDFMetalView()
                }
            } else {
                Text("Select an example")
                    .font(.title)
            }
        }
    }
    
    enum NavigationRoute: String, CaseIterable, Identifiable {
        case example1
        case example2
        case helloWorld
        case colorPicker
        case sineTransition
        case shapingFunctions
        case colorGradient
        case polarGradient
        case sdfDrawing
        
        var title: String {
            switch self {
            case .example1:
                "Basic Cross Platform MetalView"
            case .example2:
                "Protocol-based MetalView"
            case .helloWorld:
                "Hello World"
            case .colorPicker:
                "Color Picker"
            case .sineTransition:
                "Sine Transition"
            case .shapingFunctions:
                "Shaping Functions"
            case .colorGradient:
                "Color Gradient"
            case .polarGradient:
                "Polar Gradient"
            case .sdfDrawing:
                "SDF Drawing"
            }
        }
        
        var id: String { rawValue }
        
        static let simpleExamples: [NavigationRoute] = [
            .example1,
            .example2
        ]
        static let sdfDrawingExamples: [NavigationRoute] = [
            .sdfDrawing
        ]
        static let bookOfShadersExamples: [NavigationRoute] = [
            .helloWorld,
            .colorPicker,
            .sineTransition,
            .shapingFunctions,
            .colorGradient,
            .polarGradient,
        ]
    }
}

#Preview {
    MainNavigationView()
}
