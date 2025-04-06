#include <metal_stdlib>
using namespace metal;

#include "ExampleComputeShader1Params.h"

kernel void exampleComputeShader1(texture2d<half, access::write> outTexture [[texture(0)]],
                                  constant ExampleComputeShader1Params& params [[buffer(0)]],
                                  uint2 gid [[thread_position_in_grid]])
{
    // Get texture dimensions
    uint2 dims = uint2(outTexture.get_width(), outTexture.get_height());
    
    // Convert pixel position to -1 to 1 range
    float2 uv = float2(gid) / float2(dims) * 2.0 - 1.0;
    
    // Calculate distance from center
    float dist = length(uv);
    
    // Create animated rings
    float ring = sin(dist * 10.0 - params.animationPhase * 2.0) * 0.5 + 0.5;
    
    // Create a color pattern that varies with position and time
    float3 color;
    color.r = ring * (sin(params.hueRotatePhase) * 0.5 + 0.5);
    color.g = ring * (sin(params.hueRotatePhase + 2.094) * 0.5 + 0.5);
    color.b = ring * (sin(params.hueRotatePhase + 4.189) * 0.5 + 0.5);
    
    // Convert to half3 for output
    outTexture.write(half4(half3(color), 1.0), gid);
}
