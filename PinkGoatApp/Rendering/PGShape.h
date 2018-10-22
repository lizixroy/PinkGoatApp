//
//  PGShape.h
//  PinkGoatApp
//
//  Created by Roy Li on 10/3/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGShaderTypes.h"
#import "PGVertexObject.h"
#import "PGDataTypes.h"
#import <Metal/Metal.h>
#import <simd/simd.h>

@interface PGShape : NSObject

@property (nonatomic, strong) NSArray<PGVertexObject *> *vertices;
@property (nonatomic, strong) NSArray<NSNumber *> *indices;

@property (assign) matrix_float4x4 parentJointTransform;
@property (assign) matrix_float4x4 parentTransformInWorldSpace;
@property (assign) matrix_float4x4 transfromInWorldSpace;

@property (nonatomic, strong) PGShape *parent;
@property (nonatomic, strong) NSMutableArray<PGShape *> *children;

- (instancetype)initWithVertices:(NSArray<PGVertexObject *> *)vertices
                         indices:(NSArray<NSNumber *> *)indices;

- (void)makeVertices:(PGVertex *)verticesBuffer indices:(uint16_t *)indices count:(NSUInteger)count;
- (void)makeVertices:(PGVertex *)verticesBuffer count:(NSUInteger)count;
- (void)drawWithCommandEncoder:(id<MTLRenderCommandEncoder>)commandEncoder
                        device:(id<MTLDevice>)device;

@end
