//
//  MainNavigationView.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/17/25.
//

import SwiftUI

struct MainNavigationView: View {
    @State var navController = NavigationController()
    
    var body: some View {
        NavigationStack(path: $navController.path) {
            List {
                Section(header: Text("Simple Examples")) {
                    ForEach(simpleExamples) { route in
                        Button {
                            navController.push(route.navRoute)
                        } label: {
                            Text(route.title)
                        }
                    }
                }
                
                Section(header: Text("Book of Metal Shaders")) {
                    ForEach(bookOfShaderRoutes) { route in
                        Button {
                            navController.push(route.navRoute)
                        } label: {
                            Text(route.title)
                        }
                    }
                }
            }
            .navigationTitle("Metal Playground")
            .navigationDestination(for: NavigationRoute.self) { navRoute in
                switch navRoute {
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
                }
            }
        }
        .environment(navController)
    }
    
    let simpleExamples: [Route] = [
        .init(title: "Basic Cross Platform MetalView",
              navRoute: .example1),
        .init(title: "Protocol-based MetalView",
              navRoute: .example2)
    ]
    
    let bookOfShaderRoutes: [Route] = [
        .init(title: "Hello World",
              navRoute: .helloWorld),
        .init(title: "Color Picker",
              navRoute: .colorPicker),
        .init(title: "Sine Transition",
              navRoute: .sineTransition)
    ]
    
    struct Route: Identifiable {
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

enum NavigationRoute {
    case example1
    case example2
    case helloWorld
    case colorPicker
    case sineTransition
}
