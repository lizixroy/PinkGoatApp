//
//  PGCollisionShapeGraphicsGenerator.m
//  PinkGoatApp
//
//  Created by Roy Li on 10/25/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGCollisionShapeGraphicsGenerator.h"
#import "CollisionShape2TriangleMesh.h"
#import "PGShapeFactory.h"

@implementation PGCollisionShapeGraphicsGenerator

- (PGShape *)generateGraphicsForCollisionShape:(btCollisionShape *)collisionShape
{
    btTransform startTransform;
    startTransform.setIdentity();
    btAlignedObjectArray<btVector3> vertexPositions;
    btAlignedObjectArray<btVector3> vertexNormals;
    btAlignedObjectArray<int> indices;
    CollisionShape2TriangleMesh(collisionShape, startTransform, vertexPositions, vertexNormals, indices);
    btAlignedObjectArray<GLInstanceVertex> vertices;
    vertices.resize(vertexPositions.size());
    for (int i = 0; i < vertexPositions.size(); i++)
    {
        btVector3 position = vertexPositions[i];
        btVector3 normal = vertexNormals[i];
        GLInstanceVertex v;
        v.xyzw[0] = position[0];
        v.xyzw[1] = position[1];
        v.xyzw[2] = position[2];
        v.normal[0] = normal[0];
        v.normal[1] = normal[1];
        v.normal[2] = normal[2];
        vertices[i] = v;
    }
    PGShapeFactory *factory = [[PGShapeFactory alloc] init];
    PGShape *shape = [factory makeShapeFromVertices:vertices indices:indices];
    return shape;
}

@end
