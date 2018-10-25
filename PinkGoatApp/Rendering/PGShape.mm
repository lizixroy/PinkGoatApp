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

@end
