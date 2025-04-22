//
//  sineTransition.metal
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/17/25.
//

#include <metal_stdlib>
using namespace metal;

#include "SineTransitionParams.h"

kernel void sineTransition(texture2d<half, access::write> outTexture [[texture(0)]],
                           constant SineTransitionParams& params [[buffer(0)]],
                           uint2 gid [[thread_position_in_grid]])
{
    // Convert to half3 for output
    outTexture.write(half4(abs(sin(params.phase)),0.0,0.0, 1.0), gid);
}
