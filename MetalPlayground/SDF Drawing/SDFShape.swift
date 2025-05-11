//
//  SDFShape.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 5/11/25.
//

import Foundation

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
