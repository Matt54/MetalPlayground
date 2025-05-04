//
//  sdfDrawing.metal
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 5/4/25.
//

#include <metal_stdlib>
#include "SDFParams.h"
using namespace metal;

#include "../ShaderUtils/ShaderUtils.metal"
#include "../ShaderUtils/sdfPrimatives.metal"

inline float2 getCenteredCoordinates(uint2 pixelCoord, texture2d<half, access::write> texture) {
    float width = texture.get_width();
    float height = texture.get_height();
    float u = 0.5 - (float(pixelCoord.x) / width);
    float v = 0.5 - (float(pixelCoord.y) / height);
    return float2(u, v);
}

inline float getSDFValue(float2 centeredCoords, enum SDFPrimitive shape) {
    switch (shape) {
        case Circle:
            return sdfCircle(centeredCoords, 0.25);
        case Box:
            return sdfBox(centeredCoords, float2(0.25, 0.125));
        case Triangle:
            return sdfEquilateralTriangle(centeredCoords, 0.25);
        case RoundedBox:
            return sdfRoundedBox(centeredCoords, float2(0.2, 0.1), 0.05);
        case RegularPolygon:
            return sdfRegularPolygon(centeredCoords, 0.25, 6);
        case Line:
            return sdfLine(centeredCoords, float2(-0.2, -0.2), float2(0.2, 0.2), 0.02);
        case Capsule:
            return sdfCapsule(centeredCoords, float2(-0.2, -0.2), float2(0.2, 0.2), 0.05);
        case Ellipse:
            return sdfEllipse(centeredCoords, float2(0.3, 0.15));
        case Cross:
            return sdfCross(centeredCoords, float2(0.25, 0.05));
        case Star:
            return sdfStar(centeredCoords, 0.25, 0.15, 5);
    }
}

kernel void sdfDrawing(texture2d<half, access::write> destination [[texture(0)]],
                       constant SDFParams& params [[buffer(0)]],
                       uint2 pixelCoord [[thread_position_in_grid]])
{
    // Get coordinates centered at (0, 0)
    float2 centeredCoords = getCenteredCoordinates(pixelCoord, destination);
    
    // Get SDF value from the new function
    float sdf = getSDFValue(centeredCoords, params.shape);
    
    // 0 outside, 1.0 inside
    float mask = params.intensity - step(0.0, sdf);
    if (!params.shouldMask) {
         mask = params.intensity-sdf;
    }
    
    float3 color = float3(mask);                   // White outside, black inside
    destination.write(half4(half3(color), 1.0), pixelCoord);
}
