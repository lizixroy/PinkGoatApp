//
//  PGShaderTypes.h
//  PinkGoatApp
//
//  Created by Roy Li on 10/3/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#ifndef PGShaderTypes_h
#define PGShaderTypes_h

#include <simd/simd.h>

typedef enum PGVertexInputIndex
{
    PGVertexInputIndexVertices = 0,
    PGVertexInputIndexUniforms = 1,
} PGVertexInputIndex;

typedef struct
{
    // Positions in pixel space (i.e. a value of 100 indicates 100 pixels from the origin/center)
    vector_float4 position;
//    vector_float3 normal;    
    // Floating point RGBA colors
    vector_float4 color;
    
} PGVertex;


#endif /* PGShaderTypes_h */
