//
//  colorPickerShader.metal
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/17/25.
//

#include <metal_stdlib>
using namespace metal;

#include "ColorPickerParams.h"

kernel void colorPickerShader(texture2d<half, access::write> outTexture [[texture(0)]],
                              constant ColorPickerParams& params [[buffer(0)]],
                              uint2 gid [[thread_position_in_grid]])
{
    outTexture.write(half4(params.color), gid);
}
