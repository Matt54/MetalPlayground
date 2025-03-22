//
//  PlatformAliases.swift
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 3/22/25.
//

import SwiftUI

#if os(macOS)
typealias ViewRepresentable = NSViewRepresentable
typealias ViewRepresentableContext = NSViewRepresentableContext
#else
typealias ViewRepresentable = UIViewRepresentable
typealias ViewRepresentableContext = UIViewRepresentableContext
#endif
