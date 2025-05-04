//
//  Borders.metal
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 5/4/25.
//

#include <metal_stdlib>
using namespace metal;

#include "../../ShaderUtils/ShaderUtils.metal"

kernel void borders(texture2d<half, access::write> outTexture [[texture(0)]],
                         uint2 gid [[thread_position_in_grid]])
{
    float2 uv = flipped_uv(gid, outTexture);
    float2 bl = step(float2(0.1), uv);
    float2 tr = step(float2(0.1), 1.0-uv);
    float3 color = float3(bl.x*bl.y*tr.x*tr.y);
    outTexture.write(half4(half3(color), 1.0), gid);
}
