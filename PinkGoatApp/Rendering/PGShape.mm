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

@implementation PGShape

- (instancetype)initWithVertices:(NSArray<PGVertexObject *> *)vertices
                         indices:(NSArray<NSNumber *> *)indices;
{
    self = [super init];
    if (self) {
        _vertices = vertices;
        _indices = indices;
        _children = [[NSMutableArray alloc] init];
        _modelMatrix = matrix_identity_float4x4;
        _parentJointTransform = matrix_identity_float4x4;
        _parentTransformInWorldSpace = matrix_identity_float4x4;
        _transfromInWorldSpace = matrix_identity_float4x4;
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

- (void)drawWithCommandEncoder:(id<MTLRenderCommandEncoder>)commandEncoder
                        device:(id<MTLDevice>)device
          viewProjectionMatrix:(matrix_float4x4)viewProjectionMatrix
               parentTransform:(matrix_float4x4)parentTransform
{
    matrix_float4x4 modelMatrix = self.transfromInWorldSpace; //matrix_multiply(parentTransform, matrix_multiply(self.parentJointTransform, self.modelMatrix));
    if (self.vertices.count > 0) {
        id<MTLBuffer> vertexBuffer = [device newBufferWithLength:self.vertices.count * sizeof(PGVertex)
                                                         options:MTLResourceStorageModeShared];
        vertexBuffer.label = @"Vertex Buffer";
        PGVertex vertices[self.vertices.count];
        uint16_t indices[self.indices.count];
        [self makeVertices:&vertices[0] count:self.vertices.count];
        [self makeIndices:&indices[0] count:self.indices.count];
        
        memcpy(vertexBuffer.contents, &vertices[0], self.vertices.count * sizeof(PGVertex));
        id<MTLBuffer> indexBuffer = [device newBufferWithLength:self.indices.count * sizeof(uint16_t)
                                                        options:MTLResourceStorageModeShared];
        indexBuffer.label = @"Index Buffer";
        memcpy(indexBuffer.contents, &indices[0], self.indices.count * sizeof(uint16_t));
        [commandEncoder setVertexBuffer:vertexBuffer offset:0 atIndex:0];
        
        PGUniforms uniform = {
            .viewProjectionMatrix = viewProjectionMatrix,
            .modelMatrix = modelMatrix,
            .normalMatrix = matrix_identity_float3x3
        };
        
        id<MTLBuffer> uniformBuffer = [device newBufferWithLength:sizeof(PGUniforms)
                                                          options:MTLResourceStorageModeShared];
        memcpy(uniformBuffer.contents, &uniform, sizeof(uniform));
        [commandEncoder setVertexBuffer:uniformBuffer offset:0 atIndex:1];
        
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
    
//    matrix_float4x4 parentMatrixForChild = matrix_multiply(parentTransform, self.parentJointTransform);
    
//    for (PGShape *child in self.children) {
//        [child drawWithCommandEncoder:commandEncoder
//                               device:device
//                 viewProjectionMatrix:viewProjectionMatrix
//                      parentTransform:parentMatrixForChild];
//    }
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

@end
