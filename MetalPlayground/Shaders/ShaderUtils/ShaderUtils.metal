//
//  ShaderUtils.metal
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/20/25.
//

#include <metal_stdlib>
using namespace metal;

inline float2 flipped_uv(uint2 gid, texture2d<half, access::write> tex) {
    float width = tex.get_width();
    float height = tex.get_height();
    return float2(gid.x / width, 1.0 - (gid.y / height));
}
