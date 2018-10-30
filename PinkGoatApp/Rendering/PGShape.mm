//
//  PGShape.m
//  PinkGoatApp
//
//  Created by Roy Li on 10/3/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGShape.h"
#include <simd/simd.h>
#import "PGShaderTypes.h"
#import "PGMatrixLogger.h"
#import "NSColor+Vector.h"

@implementation PGShape

- (instancetype)initWithVertices:(NSArray<PGVertexObject *> *)vertices
                         indices:(NSArray<NSNumber *> *)indices;
{
    self = [super init];
    if (self) {
        _vertices = vertices;
        _indices = indices;
        _sceneNode = [self toSceneNode];
    }
    return self;
}

- (void)makeVertices:(nonnull PGVertex *)verticesBuffer count:(NSUInteger)count;
{
    for (int i = 0; i < count; i++) {
        PGVertexObject *vertexObject = self.vertices[i];
        vector_float4 position = { vertexObject.position.x, vertexObject.position.y, vertexObject.position.z, 1 };
        PGVertex vertex = { position, vertexObject.normal, vertexObject.color };
        memcpy(&verticesBuffer[i], &vertex, sizeof(vertex));
    }
}

- (void)makeIndices:(nonnull uint16_t *)indicesBuffer count:(NSUInteger)count;
{
    for (int i = 0; i < count; i++) {
        NSNumber *indexObject = self.indices[i];
        uint16_t index = indexObject.unsignedIntValue;
        memcpy(&indicesBuffer[i], &index, sizeof(index));
    }
}

- (NSData *)makeRawVertexData
{
    NSMutableData *data = [[NSMutableData alloc] init];
    for (int i = 0; i < self.vertices.count; i++) {
        PGVertexObject *vertexObject = self.vertices[i];
        float positionX = vertexObject.position.x;
        float positionY = vertexObject.position.y;
        float positionZ = vertexObject.position.z;
        float positionW = vertexObject.position.w;
        
        [data appendBytes:&positionX length:sizeof(float)];
        [data appendBytes:&positionY length:sizeof(float)];
        [data appendBytes:&positionZ length:sizeof(float)];
        [data appendBytes:&positionW length:sizeof(float)];

        
        float normalX = vertexObject.normal.x;
        float normalY = vertexObject.normal.y;
        float normalZ = vertexObject.normal.z;
        
        [data appendBytes:&normalX length:sizeof(float)];
        [data appendBytes:&normalY length:sizeof(float)];
        [data appendBytes:&normalZ length:sizeof(float)];
        
        float colorX = vertexObject.color.x;
        float colorY = vertexObject.color.y;
        float colorZ = vertexObject.color.z;
        float colorW = vertexObject.color.w;
        
        [data appendBytes:&colorX length:sizeof(float)];
        [data appendBytes:&colorY length:sizeof(float)];
        [data appendBytes:&colorZ length:sizeof(float)];
        [data appendBytes:&colorW length:sizeof(float)];
    }
    return [NSData dataWithData:data];
}

- (NSData *)makeRawIndexData
{
    NSMutableData *data = [[NSMutableData alloc] init];
    for (int i = 0; i < self.indices.count; i++) {
        NSNumber *indexObject = self.indices[i];
        uint32 index = indexObject.unsignedIntValue;
        [data appendBytes:&index length:sizeof(uint32)];
    }
    return [NSData dataWithData:data];
}

- (SCNNode *)toSceneNode
{
    NSData *vertexRawData = [self makeRawVertexData];
    NSData *indexRawData = [self makeRawIndexData];
    
    MDLVertexDescriptor *descriptor = [[MDLVertexDescriptor alloc] init];
    descriptor.attributes[0] = [[MDLVertexAttribute alloc] initWithName:MDLVertexAttributePosition
                                                                  format:MDLVertexFormatFloat4
                                                                  offset:0
                                                             bufferIndex:0];
    descriptor.attributes[1] = [[MDLVertexAttribute alloc] initWithName:MDLVertexAttributeNormal
                                                                 format:MDLVertexFormatFloat3
                                                                 offset:sizeof(float) * 4
                                                            bufferIndex:0];
    
    descriptor.attributes[2] = [[MDLVertexAttribute alloc] initWithName:MDLVertexAttributeColor
                                                                 format:MDLVertexFormatFloat4
                                                                 offset:sizeof(float) * 7
                                                            bufferIndex:0];
    // lack of layout will crash the program with no error message.
    descriptor.layouts[0] = [[MDLVertexBufferLayout alloc] initWithStride:sizeof(float) * 11];
    MDLMeshBufferDataAllocator *allocator = [[MDLMeshBufferDataAllocator alloc] init];
    id<MDLMeshBuffer> meshBuffer = [allocator newBufferWithData:vertexRawData type:MDLMeshBufferTypeVertex];
    id<MDLMeshBuffer> indexBuffer = [allocator newBufferWithData:indexRawData type:MDLMeshBufferTypeIndex];
    
    MDLSubmesh *submesh = [[MDLSubmesh alloc] initWithIndexBuffer:indexBuffer indexCount:indexRawData.length / sizeof(uint32) indexType:MDLIndexBitDepthUInt32 geometryType:MDLGeometryTypeTriangles material:nil];
    MDLMesh *mesh = [[MDLMesh alloc] initWithVertexBuffer:meshBuffer vertexCount: vertexRawData.length / (sizeof(float) * 11) descriptor:descriptor submeshes:@[submesh]];
    SCNGeometry *geo = [SCNGeometry geometryWithMDLMesh:mesh];
    SCNNode *node = [SCNNode nodeWithGeometry:geo];
    return node;
}

- (void)setColor:(NSColor *)color
{
    for (PGVertexObject *vertex in self.vertices) {
        vertex.color = color.vectorForm;
    }
    self.sceneNode = [self toSceneNode];
}

@end
