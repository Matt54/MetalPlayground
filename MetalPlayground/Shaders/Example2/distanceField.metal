#include <metal_stdlib>
#include "DistanceFieldParams.h"
using namespace metal;

// Ported from:
// https://thebookofshaders.com/07/
kernel void distanceField(texture2d<half, access::write> outTexture [[texture(0)]],
                          constant DistanceFieldParams& params [[buffer(0)]],
                          uint2 gid [[thread_position_in_grid]])
{
    uint2 dims = uint2(outTexture.get_width(), outTexture.get_height());
    float2 uv = float2(gid) / float2(dims);
    
    // Calculate distance from center
    // note: these all work the same
    
    // a. The DISTANCE from the pixel to the center
//    float dist = distance(uv, float2(0.5));
    
    // b. The LENGTH of the vector
//    float2 toCenter = float2(0.5)-uv;
//    float dist = length(toCenter);
    
    // c. The SQUARE ROOT of the vector
    float2 tC = float2(0.5)-uv;
    float dist = sqrt(tC.x*tC.x+tC.y*tC.y);
    
    dist = smoothstep(0.1,params.width, dist);
    
    // Create a color pattern that varies with position and time
    float3 color = float3(dist);
    
    // Convert to half3 for output
    outTexture.write(half4(half3(color), 1.0), gid);
}
