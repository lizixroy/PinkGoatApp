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
#import <SceneKit/SceneKit.h>
#import <ModelIO/ModelIO.h>
#import <SceneKit/ModelIO.h>

@interface PGShape : NSObject

@property (nonatomic, strong) NSArray<PGVertexObject *> *vertices;
@property (nonatomic, strong) NSArray<NSNumber *> *indices;
@property (nonatomic, strong) SCNNode *sceneNode;

@property (assign) matrix_float4x4 modelMatrix;
@property (assign) matrix_float4x4 parentJointTransform;
@property (assign) matrix_float4x4 parentTransformInWorldSpace;
@property (assign) matrix_float4x4 transfromInWorldSpace;

@property (nonatomic, strong) PGShape *parent;
@property (nonatomic, strong) NSMutableArray<PGShape *> *children;
@property (nonatomic, strong) NSString *name;

- (instancetype)initWithVertices:(NSArray<PGVertexObject *> *)vertices
                         indices:(NSArray<NSNumber *> *)indices;

- (void)drawWithCommandEncoder:(id<MTLRenderCommandEncoder>)commandEncoder
                        device:(id<MTLDevice>)device
          viewProjectionMatrix:(matrix_float4x4)viewProjectionMatrix
               parentTransform:(matrix_float4x4)parentTransform;

- (SCNNode *)toSceneNode;

@end
