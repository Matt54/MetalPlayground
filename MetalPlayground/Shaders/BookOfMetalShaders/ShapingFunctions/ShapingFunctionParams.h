//
//  ShapingFunctionParams.h
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/22/25.
//

#pragma once

#include <simd/simd.h>

struct ExponentialFunctionParams {
    float exponent;
};

struct StepFunctionParams {
    float threshold;
};

struct SmoothStepFunctionParams {
    float edge0;
    float edge1;
};

struct LogFunctionParams {
    float base;
    float offset;
};

struct SqrtFunctionParams {
    float scale;
};

struct ExpImpulseParams {
    float k;
};

struct SincFunctionParams {
    float k;
    float addition;
};

struct ToneFunctionParams {
    float k;
};

struct CubicPulseParams {
    float center;
    float width;
};
