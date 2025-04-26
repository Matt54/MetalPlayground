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

// Returns a smooth band around the target Y-value.
// Useful for plotting scalar functions as soft lines in 2D space.
//
// Parameters:
// - st: The fragment coordinate in normalized space [0,1]
// - targetY: The Y value of the function you're visualizing (e.g. f(st.x))
//
// Returns:
// - A value near 1.0 where st.y is close to targetY, tapering to 0.0 outside a narrow range.
inline float plot(float2 st, float targetY, float thickness) {
    return smoothstep(targetY - thickness, targetY, st.y) -
           smoothstep(targetY, targetY + thickness, st.y);
}

inline float plot(float2 st, float targetY) {
    return plot(st, targetY, 0.02);
}
