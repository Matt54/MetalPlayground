//
//  helloWorld.metal
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 4/17/25.
//

#include <metal_stdlib>
using namespace metal;

kernel void helloWorld(texture2d<half, access::write> outTexture [[texture(0)]],
                       uint2 gid [[thread_position_in_grid]])
{
    outTexture.write(half4(1.0,0.0,1.0,1.0), gid);
}
