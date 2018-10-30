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
#import <simd/simd.h>
#import <SceneKit/SceneKit.h>
#import <ModelIO/ModelIO.h>
#import <SceneKit/ModelIO.h>

@interface PGShape : NSObject

@property (nonatomic, strong) NSArray<PGVertexObject *> *vertices;
@property (nonatomic, strong) NSArray<NSNumber *> *indices;
@property (nonatomic, strong) SCNNode *sceneNode;

@property (nonatomic, strong) NSString *name;

- (instancetype)initWithVertices:(NSArray<PGVertexObject *> *)vertices
                         indices:(NSArray<NSNumber *> *)indices;
- (SCNNode *)toSceneNode;

/**
    Set the color of the entire shape to the new color. This method will primarily be used for changing colors of shapes based solely on collision shapes.
    This will change the color of associated SCNNode immediately.
 */
- (void)setColor:(NSColor *)color;

- (void)makeVertices:(PGVertex *)verticesBuffer count:(NSUInteger)count;

@end
