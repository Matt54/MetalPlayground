//
//  colorGradient.metal
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/27/25.
//

#include <metal_stdlib>
using namespace metal;

#include "../../ShaderUtils/ShaderUtils.metal"

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
    
    // Normalize angle to [0,1] range
    float normalizedAngle = (angle / (2.0 * M_PI_F)) + 0.5;
    
    color = hsb2rgb(float3(normalizedAngle, radius, 1.0));
    
    outTexture.write(half4(half3(color), 1.0), gid);
}
