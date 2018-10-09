//
//  PGShape.m
//  PinkGoatApp
//
//  Created by Roy Li on 10/3/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGShape.h"
#include <simd/simd.h>

@implementation PGShape

- (instancetype)initWithVertices:(NSArray<PGVertexObject *> *)vertices
                         indices:(NSArray<NSNumber *> *)indices;
{
    self = [super init];
    if (self) {
        _vertices = vertices;
        _indices = indices;
    }
    return self;
}

- (void)makeVertices:(nonnull PGVertex *)verticesBuffer count:(NSUInteger)count;
{
    for (int i = 0; i < count; i++) {
        if (i >= self.vertices.count) {
            break;
        }
        PGVertexObject *vertexObject = self.vertices[i];
        vector_float4 position = { vertexObject.position.x, vertexObject.position.y, vertexObject.position.z, 1 };
        PGVertex vertex = { position, vertexObject.normal, vertexObject.color };
        memcpy(&verticesBuffer[i], &vertex, sizeof(vertex));
    }
}

@end
