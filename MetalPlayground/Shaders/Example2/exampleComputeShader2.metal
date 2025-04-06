#include <metal_stdlib>
using namespace metal;

#include "ExampleComputeShader2Params.h"

float sdCircle(float2 p, float r)
{
    return length(p)-r;
}

kernel void exampleComputeShader2(texture2d<half, access::write> outTexture [[texture(0)]],
                                  constant ExampleComputeShader2Params& params [[buffer(0)]],
                                  uint2 gid [[thread_position_in_grid]])
{
    // Get texture dimensions
    uint2 dims = uint2(outTexture.get_width(), outTexture.get_height());
    
    // Convert pixel position to -1 to 1 range
    float2 uv = float2(gid) / float2(dims) * 2.0 - 1.0;
    
    // Calculate box-like distance from the center
    float dist;
    if (params.isBox > 0) {
        // box
        dist = max(abs(uv.x), abs(uv.y));
    } else {
        // circle
        dist = length(uv);
    }
    
    // Define box size and expansion speed
    float size = 0.05;
    float spacing = 0.15;
    float speed = 0.5;

    // Create expanding boxes (continuous)
    float wave = sin((dist - params.animationPhase * speed) * 10.0) * 0.5 + 0.5;
    float box = step(fract(dist / spacing), size) * wave;

    // Create a color pattern that varies with time
    float3 color;
    color.r = box * (sin(params.hueRotatePhase) * 0.5 + 0.5);
    color.g = box * (sin(params.hueRotatePhase + 2.094) * 0.5 + 0.5);
    color.b = box * (sin(params.hueRotatePhase + 4.189) * 0.5 + 0.5);

    // Output the color
    outTexture.write(half4(half3(color), 1.0), gid);
}
