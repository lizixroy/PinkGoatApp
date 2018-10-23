//
//  PGSceneNodeBuilder.m
//  PinkGoatApp
//
//  Created by Roy Li on 10/20/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGSceneNodeBuilder.h"
#import "PGLogger.h"
#import "GLInstanceGraphicsShape.h"
#include <simd/simd.h>
#import "PGObjcMathUtilities.h"

@implementation PGSceneNodeBuilder

- (PGShape *)buildSceneNodeWithURDFImporter:(BulletURDFImporter&)urdfImporter
                                  linkIndex:(int)linkIndex
{
    btTransform parent2joint;
    parent2joint.setIdentity();
    
    int jointType;
    btVector3 jointAxisInJointSpace;
    btScalar jointLowerLimit;
    btScalar jointUpperLimit;
    btScalar jointDamping;
    btScalar jointFriction;
    btScalar jointMaxForce;
    btScalar jointMaxVelocity;
    btTransform linkTransformInWorldSpace;
    linkTransformInWorldSpace.setIdentity();

    bool hasParentJoint = urdfImporter.getJointInfo2(linkIndex, parent2joint, linkTransformInWorldSpace, jointAxisInJointSpace, jointType,jointLowerLimit,jointUpperLimit, jointDamping, jointFriction,jointMaxForce,jointMaxVelocity);
    
//    [PGLogger logTransform:parent2joint];
    btAlignedObjectArray<GLInstanceVertex> vertices;
    btAlignedObjectArray<int> indices;
    urdfImporter.getVerticesAndIndicesForLinkIndex(vertices, indices, linkIndex);
    NSArray<PGVertexObject *> *vertexObjects = [self createVertexObjectsFromGLInstanceVertexArray:vertices];
    NSArray<NSNumber *> *indexObjects = [self createIndexObjectsFromIndexArray:indices];
    PGShape *shape = [[PGShape alloc] initWithVertices:vertexObjects indices:indexObjects];
    
    shape.parentJointTransform = [PGObjcMathUtilities getMatrixFromTransfrom:parent2joint];
    // TODO: parentTransformInWorldSpace is not valid. We also need to get local inertia to get all the info we need for rendering
    shape.parentTransformInWorldSpace = [PGObjcMathUtilities getMatrixFromTransfrom:linkTransformInWorldSpace];
    
//    NSLog(@"parentJointTransform:");
//    [PGLogger logTransform:parent2joint];
//    NSLog(@"linkTransformInWorldSpace:");
//    [PGLogger logTransform:linkTransformInWorldSpace];
    
    btAlignedObjectArray<int> childLinkIndices;
    urdfImporter.getLinkChildIndices(linkIndex, childLinkIndices);
    for (int i = 0; i < childLinkIndices.size(); i++) {
        int childIndex = childLinkIndices[i];
        [shape.children addObject:[self buildSceneNodeWithURDFImporter:urdfImporter linkIndex:childIndex]];
    }
    return shape;
}

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

@end
