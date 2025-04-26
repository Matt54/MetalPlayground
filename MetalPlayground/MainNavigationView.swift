//
//  MainNavigationView.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/17/25.
//

import SwiftUI

struct MainNavigationView: View {
    @State var navController = NavigationController()
    @State private var columnVisibility = NavigationSplitViewVisibility.automatic
    @State private var selectedRoute: Route?
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selectedRoute) {
                Section("Simple Examples") {
                    ForEach(Self.simpleExamples) { route in
                        NavigationLink(value: route) {
                            Text(route.title)
                                .tag(route)
                        }
                    }
                }
                
                Section("Book of Shaders") {
                    ForEach(Self.bookOfShaderRoutes) { route in
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
                switch route.navRoute {
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
                }
            } else {
                Text("Select an example")
            }
        }
    }
    
    let allRoutes: [Route] = simpleExamples + bookOfShaderRoutes
    
    static let simpleExamples: [Route] = [
        .init(title: "Basic Cross Platform MetalView",
              navRoute: .example1),
        .init(title: "Protocol-based MetalView",
              navRoute: .example2)
    ]
    
    static let bookOfShaderRoutes: [Route] = [
        .init(title: "Hello World", navRoute: .helloWorld),
        .init(title: "Color Picker", navRoute: .colorPicker),
        .init(title: "Sine Transition", navRoute: .sineTransition),
        .init(title: "Shaping Functions", navRoute: .shapingFunctions)
    ]

    struct Route: Identifiable, Hashable {
        let id = UUID()
        let title: String
        let navRoute: NavigationRoute
    }
}

#Preview {
    MainNavigationView()
}

@Observable
class NavigationController {
    var path: [NavigationRoute] = []
    
    func push(_ route: NavigationRoute) {
        path.append(route)
    }
}

enum NavigationRoute: CaseIterable {
    case example1
    case example2
    case helloWorld
    case colorPicker
    case sineTransition
    case shapingFunctions
}
