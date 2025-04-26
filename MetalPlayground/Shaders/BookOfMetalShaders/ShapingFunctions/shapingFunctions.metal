//
//  shapingFunctions.metal
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/22/25.
//

#include <metal_stdlib>
using namespace metal;

#include "../../ShaderUtils/ShaderUtils.metal"
#include "ShapingFunctionParams.h"

kernel void linearInterpolation(texture2d<half, access::write> outTexture [[texture(0)]],
                                uint2 gid [[thread_position_in_grid]])
{
    float2 uv = flipped_uv(gid, outTexture);
    
    float y = uv.x;
    
    float3 color = float3(y);
    
    float pct = plot(uv, y);
    color = (1.0 - pct) * color + pct * float3(0.0, 1.0, 0.0);
    
    outTexture.write(half4(half3(color), 1.0), gid);
}


kernel void exponentialFunction(texture2d<half, access::write> outTexture [[texture(0)]],
                                constant ExponentialFunctionParams& params [[buffer(0)]],
                                uint2 gid [[thread_position_in_grid]])
{
    float2 uv = flipped_uv(gid, outTexture);
    
    float y = pow(uv.x, params.exponent);
    
    float3 color = float3(y);
    
    float pct = plot(uv, y);
    color = (1.0 - pct) * color + pct * float3(0.0, 1.0, 0.0);
    
    outTexture.write(half4(half3(color), 1.0), gid);
}

kernel void stepFunction(texture2d<half, access::write> outTexture [[texture(0)]],
                        constant StepFunctionParams& params [[buffer(0)]],
                        uint2 gid [[thread_position_in_grid]])
{
    float2 uv = flipped_uv(gid, outTexture);
    
    float y = step(params.threshold, uv.x);
    
    float3 color = float3(y);
    
    float pct = plot(uv, y);
    color = (1.0 - pct) * color + pct * float3(0.0, 1.0, 0.0);
    
    outTexture.write(half4(half3(color), 1.0), gid);
}

kernel void smoothStepFunction(texture2d<half, access::write> outTexture [[texture(0)]],
                             constant SmoothStepFunctionParams& params [[buffer(0)]],
                             uint2 gid [[thread_position_in_grid]])
{
    float2 uv = flipped_uv(gid, outTexture);
    
    float y = smoothstep(params.edge0, params.edge1, uv.x);
    
    float3 color = float3(y);
    
    float pct = plot(uv, y);
    color = (1.0 - pct) * color + pct * float3(0.0, 1.0, 0.0);
    
    outTexture.write(half4(half3(color), 1.0), gid);
}

kernel void logFunction(texture2d<half, access::write> outTexture [[texture(0)]],
                       constant LogFunctionParams& params [[buffer(0)]],
                       uint2 gid [[thread_position_in_grid]])
{
    float2 uv = flipped_uv(gid, outTexture);
    
    // Add offset to avoid log(0) and ensure positive input
    float x = uv.x + params.offset;
    float y = log(x) / log(params.base);
    
    float3 color = float3(y);
    
    float pct = plot(uv, y);
    color = (1.0 - pct) * color + pct * float3(0.0, 1.0, 0.0);
    
    outTexture.write(half4(half3(color), 1.0), gid);
}

kernel void sqrtFunction(texture2d<half, access::write> outTexture [[texture(0)]],
                        constant SqrtFunctionParams& params [[buffer(0)]],
                        uint2 gid [[thread_position_in_grid]])
{
    float2 uv = flipped_uv(gid, outTexture);
    
    float y = sqrt(uv.x * params.scale);
    
    float3 color = float3(y);
    
    float pct = plot(uv, y);
    color = (1.0 - pct) * color + pct * float3(0.0, 1.0, 0.0);
    
    outTexture.write(half4(half3(color), 1.0), gid);
}

kernel void expImpulseFunction(texture2d<half, access::write> outTexture [[texture(0)]],
                              constant ExpImpulseParams& params [[buffer(0)]],
                              uint2 gid [[thread_position_in_grid]])
{
    float2 uv = flipped_uv(gid, outTexture);
    
    float h = params.k * uv.x;
    float y = h * exp(1.0 - h);
    
    float3 color = float3(y);
    
    float pct = plot(uv, y);
    color = (1.0 - pct) * color + pct * float3(0.0, 1.0, 0.0);
    
    outTexture.write(half4(half3(color), 1.0), gid);
}

kernel void sincFunction(texture2d<half, access::write> outTexture [[texture(0)]],
                        constant SincFunctionParams& params [[buffer(0)]],
                        uint2 gid [[thread_position_in_grid]])
{
    float2 uv = flipped_uv(gid, outTexture);
    
    float a = M_PI_F * (params.k * uv.x - 1.0);
    float y = sin(a) / a + params.addition;
    
    float3 color = float3(y);
    
    float pct = plot(uv, y);
    color = (1.0 - pct) * color + pct * float3(0.0, 1.0, 0.0);
    
    outTexture.write(half4(half3(color), 1.0), gid);
}

kernel void cubicPulseFunction(texture2d<half, access::write> outTexture [[texture(0)]],
                             constant CubicPulseParams& params [[buffer(0)]],
                             uint2 gid [[thread_position_in_grid]])
{
    float2 uv = flipped_uv(gid, outTexture);
    
    float x = abs(uv.x - params.center);
    float y = 0.0;
    if (x <= params.width) {
        x /= params.width;
        y = 1.0 - x * x * (3.0 - 2.0 * x);
    }
    
    float3 color = float3(y);
    
    float pct = plot(uv, y);
    color = (1.0 - pct) * color + pct * float3(0.0, 1.0, 0.0);
    
    outTexture.write(half4(half3(color), 1.0), gid);
}
