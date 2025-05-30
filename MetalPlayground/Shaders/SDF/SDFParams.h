#pragma once

#include <simd/simd.h>
#include "SDFPrimitive.h"

struct SDFParams {
    int shouldMask;
    enum SDFPrimitive shape;
    float intensity;
    simd_float2 repetitions;
    int shouldFlipAlternating;
    float rotation;
    float blendK;
    float scale;
    float shellThickness;
    int shouldMakeAnnular;
    float patternFrequency;
    int shouldApplyPattern;
    float patternPhase;
    float contrast;
};
