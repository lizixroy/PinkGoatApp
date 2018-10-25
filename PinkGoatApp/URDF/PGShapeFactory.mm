//
//  PGSceneNodeBuilder.m
//  PinkGoatApp
//
//  Created by Roy Li on 10/20/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGShapeFactory.h"
#import "PGLogger.h"
#include <simd/simd.h>
#import "PGObjcMathUtilities.h"

@implementation PGShapeFactory

- (NSArray<PGVertexObject *> *)createVertexObjectsFromGLInstanceVertexArray:(btAlignedObjectArray<GLInstanceVertex>)vertexArray
{
    NSMutableArray<PGVertexObject *> *vertices = [[NSMutableArray alloc] init];
    for (int i = 0; i < vertexArray.size(); i++) {
        GLInstanceVertex v = vertexArray[i];
        vector_float4 position = { v.xyzw[0], v.xyzw[1], v.xyzw[2], v.xyzw[3] };
        vector_float3 normal = { v.normal[0], v.normal[1], v.normal[2] };
        PGVertexObject *vertex = [[PGVertexObject alloc] initWithPosition:position normal:normal];

        [vertices addObject:vertex];
    }
    return [NSArray arrayWithArray:vertices];
}

- (NSArray<NSNumber *> *)createIndexObjectsFromIndexArray:(btAlignedObjectArray<int>)indexArray
{
    NSMutableArray<NSNumber *> *indices = [[NSMutableArray alloc] init];
    for (int i = 0; i < indexArray.size(); i++) {
        [indices addObject: [NSNumber numberWithInt:indexArray[i]]];
    }
    return [NSArray arrayWithArray:indices];
}

- (PGShape *)makeShapeFromVertices:(btAlignedObjectArray<GLInstanceVertex> &)vertices indices:(btAlignedObjectArray<int> &)indices;
{
    NSArray<PGVertexObject *> *vertexObjects = [self createVertexObjectsFromGLInstanceVertexArray:vertices];
    NSArray<NSNumber *> *indexObjects = [self createIndexObjectsFromIndexArray:indices];
    PGShape *shape = [[PGShape alloc] initWithVertices:vertexObjects indices:indexObjects];
    return shape;
}

@end
