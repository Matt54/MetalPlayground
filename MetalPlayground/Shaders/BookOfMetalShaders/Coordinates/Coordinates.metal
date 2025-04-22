//
//  Coordinates.metal
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/17/25.
//

#include <metal_stdlib>
using namespace metal;

#include "../../ShaderUtils/ShaderUtils.metal"

kernel void coordinates(texture2d<half, access::write> outTexture [[texture(0)]],
                        uint2 gid [[thread_position_in_grid]])
{
    float2 uv = flipped_uv(gid, outTexture);
    outTexture.write(half4(uv.x, uv.y, 0.0, 1.0), gid);
}
