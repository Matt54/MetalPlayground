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

// Add a rotation helper function
inline float2 rotate2D(float2 p, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return float2(p.x * c - p.y * s, p.x * s + p.y * c);
}

inline float2 createRepetitionPattern(float2 coords, float2 repetitions, bool shouldFlip) {
    // For odd repetitions, we want to center the pattern
    float2 offset = float2(
        fmod(repetitions.x, 2.0) != 0.0 ? 0.5/repetitions.x : 0.0,
        fmod(repetitions.y, 2.0) != 0.0 ? 0.5/repetitions.y : 0.0
    );
    
    // Apply offset to input coordinates before scaling
    coords += offset;
    
    // Scale up coordinates to create multiple repetitions
    float2 scaled = coords * repetitions;
    
    // Get cell indices and local coordinates
    float2 cell = floor(scaled);
    float2 local = fract(scaled) - 0.5;
    
    // Only apply flipping if the parameter is enabled
    if (shouldFlip) {
        bool shouldFlipX = (int(cell.x) & 1) == 1;
        bool shouldFlipY = (int(cell.y) & 1) == 1;
        
        if (shouldFlipX) local.x = -local.x;
        if (shouldFlipY) local.y = -local.y;
    }
    
    return local;
}

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
            return sdfHexagon(centeredCoords, 0.25);
        case Line:
            return sdfLine(centeredCoords, float2(-0.2, -0.2), float2(0.2, 0.2), 0.02);
        case Capsule:
            return sdfCapsule(centeredCoords, float2(-0.2, -0.2), float2(0.2, 0.2), 0.05);
        case Ellipse:
            return sdfEllipse(centeredCoords, float2(0.3, 0.15));
        case Cross:
            return sdfCross(centeredCoords, float2(0.25, 0.0625), 0.0125);
        case Pentagram:
            return sdfPentagram(centeredCoords, 0.25);
    }
}

kernel void sdfDrawing(texture2d<half, access::write> destination [[texture(0)]],
                       constant SDFParams& params [[buffer(0)]],
                       uint2 pixelCoord [[thread_position_in_grid]])
{
    // Get base coordinates centered at (0, 0)
    float2 coordinates = getCenteredCoordinates(pixelCoord, destination);
    
    // Create repetition pattern
    coordinates = createRepetitionPattern(coordinates, params.repetitions, params.shouldFlipAlternating != 0);
    
    // Apply rotation after pattern creation
    coordinates = rotate2D(coordinates, params.rotation);
    
    // Get SDF value from the new function
    float sdf = getSDFValue(coordinates, params.shape);
    
    // 0 outside, 1.0 inside
    float mask = params.intensity - step(0.0, sdf);
    if (!params.shouldMask) {
         mask = params.intensity-sdf;
    }
    
    float3 color = float3(mask);                   // White outside, black inside
    destination.write(half4(half3(color), 1.0), pixelCoord);
}
