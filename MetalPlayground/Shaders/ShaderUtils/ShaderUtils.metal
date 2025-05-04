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

// Convert RGB to HSB (HSV)
inline float3 rgb2hsb(float3 c) {
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = mix(float4(c.bg, K.wz),
                   float4(c.gb, K.xy),
                   step(c.b, c.g));
    float4 q = mix(float4(p.xyw, c.r),
                   float4(c.r, p.yzx),
                   step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)),
                  d / (q.x + e),
                  q.x);
}

//  Function from Iñigo Quiles
//  https://www.shadertoy.com/view/MsS3Wc
inline float3 hsb2rgb(float3 c) {
    float3 rgb = clamp(abs(fmod(c.x * 6.0 + float3(0.0, 4.0, 2.0),
                               6.0) - 3.0) - 1.0,
                       0.0,
                       1.0);
    rgb = rgb * rgb * (3.0 - 2.0 * rgb);
    return c.z * mix(float3(1.0), rgb, c.y);
}
