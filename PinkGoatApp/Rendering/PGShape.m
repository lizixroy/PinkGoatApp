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
        _children = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)makeVertices:(PGVertex *)verticesBuffer indices:(uint16_t *)indices count:(NSUInteger)count;
{
    for (int i = 0; i < count; i++) {
        if (i >= self.vertices.count) {
            break;
        }
        PGVertexObject *vertexObject = self.vertices[i];
        NSNumber *indexObject = self.indices[i];
        
        vector_float4 position = { vertexObject.position.x, vertexObject.position.y, vertexObject.position.z, 1 };
        PGVertex vertex = { position, vertexObject.normal, vertexObject.color };
        memcpy(&verticesBuffer[i], &vertex, sizeof(vertex));
        
        uint16_t index = (uint16_t) indexObject.unsignedIntValue;
        memcpy(&indices[i], &index, sizeof(int));
    }
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

- (void)drawWithCommandEncoder:(id<MTLRenderCommandEncoder>)commandEncoder
                        device:(id<MTLDevice>)device;
{
    id<MTLBuffer> vertexBuffer = [device newBufferWithLength:self.vertices.count * sizeof(PGVertex)
                                                     options:MTLResourceStorageModeShared];
    vertexBuffer.label = @"Vertex Buffer";
    PGVertex vertices[self.vertices.count];
    uint16_t indices[self.vertices.count];
    [self makeVertices:&vertices[0] indices:&indices[0] count:self.vertices.count];
    memcpy(vertexBuffer.contents, &vertices[0], self.vertices.count * sizeof(PGVertex));
    
    id<MTLBuffer> indexBuffer = [device newBufferWithLength:self.indices.count * sizeof(uint16_t)
                                                    options:MTLResourceStorageModeShared];
    indexBuffer.label = @"Index Buffer";
    memcpy(indexBuffer.contents, &indices[0], self.indices.count * sizeof(uint16_t));
    [commandEncoder setVertexBuffer:vertexBuffer offset:0 atIndex:0];
    
    if (self.indices.count > 0) {
        [commandEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                                   indexCount:self.indices.count
                                    indexType:MTLIndexTypeUInt16
                                  indexBuffer:indexBuffer
                            indexBufferOffset:0];
    } else {
        [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:self.vertices.count];
    }
}


@end
