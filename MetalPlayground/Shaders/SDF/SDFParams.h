#pragma once

#include <simd/simd.h>
#include "SDFPrimitive.h"

struct SDFParams {
    int shouldMask;
    enum SDFPrimitive shape;     // Need 'enum' keyword in C/Metal
    float intensity;
};
