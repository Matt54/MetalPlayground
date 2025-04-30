//
//  colorGradient.metal
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/27/25.
//

#include <metal_stdlib>
using namespace metal;

#include "../../ShaderUtils/ShaderUtils.metal"

// Convert RGB to HSB (HSV)
float3 rgb2hsb(float3 c) {
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
float3 hsb2rgb(float3 c) {
    float3 rgb = clamp(abs(fmod(c.x * 6.0 + float3(0.0, 4.0, 2.0),
                               6.0) - 3.0) - 1.0,
                       0.0,
                       1.0);
    rgb = rgb * rgb * (3.0 - 2.0 * rgb);
    return c.z * mix(float3(1.0), rgb, c.y);
}

kernel void colorGradient(texture2d<half, access::write> outTexture [[texture(0)]],
                         uint2 gid [[thread_position_in_grid]])
{
    float2 uv = flipped_uv(gid, outTexture);
    
    // Map x to hue and y to brightness, with saturation fixed at 1.0
    float3 color = hsb2rgb(float3(uv.x, 1.0, uv.y));
    
    outTexture.write(half4(half3(color), 1.0), gid);
}

kernel void polarColorGradient(texture2d<half, access::write> outTexture [[texture(0)]],
                             uint2 gid [[thread_position_in_grid]])
{
    float2 uv = flipped_uv(gid, outTexture);
    float3 color = float3(0.0);
    
    // Use polar coordinates instead of cartesian
    float2 toCenter = float2(0.5) - uv;
    float angle = atan2(toCenter.y, toCenter.x);
    float radius = length(toCenter) * 2.0;
    
    // Map the angle (-PI to PI) to the Hue (from 0 to 1)
    // and the Saturation to the radius
    color = hsb2rgb(float3((angle / (2.0 * M_PI_F)) + 0.5, radius, 1.0));
    
    outTexture.write(half4(half3(color), 1.0), gid);
}