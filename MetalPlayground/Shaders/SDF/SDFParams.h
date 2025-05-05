#pragma once

#include <simd/simd.h>
#include "SDFPrimitive.h"

struct SDFParams {
    int shouldMask;
    enum SDFPrimitive shape;     // Need 'enum' keyword in C/Metal
    float intensity;
    simd_float2 repetitions;    // Changed from float2 to simd_float2
    int shouldFlipAlternating;   // Add this new parameter
    float rotation;    // Add rotation in radians
};
