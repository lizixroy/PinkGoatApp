//
//  PGVertexFactory.m
//  PinkGoatApp
//
//  Created by Roy Li on 9/29/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGVertexFactory.h"
#import "../bullet/BulletCollision/CollisionShapes/btCompoundShape.h"
#import "../bullet/BulletCollision/CollisionShapes/btSphereShape.h"
#import "../ShapeData.h"
#import "../CollisionShape2TriangleMesh.h"

enum
{
    B3_GL_TRIANGLES = 1,
    B3_GL_POINTS
};

@implementation PGVertexFactory

- (GLInstanceVertex *)makeVertexFromCollisionObject:(btCollisionObject *)collisionObject
{
    return nil;
}

void createCollisionShapeGraphicsObject(btCollisionShape* collisionShape)
{
    //already has a graphics object?
    if (collisionShape->getUserIndex()>=0)
        return;
    
    btAlignedObjectArray<GLInstanceVertex> gfxVertices;
    btAlignedObjectArray<int> indices;
    
    btTransform startTrans;startTrans.setIdentity();
    //todo: create some textured objects for popular objects, like plane, cube, sphere, capsule
    {
        btAlignedObjectArray<btVector3> vertexPositions;
        btAlignedObjectArray<btVector3> vertexNormals;
        
        printf("<%s %d> Getting vertex positions, normals and indices\n", __FILE__, __LINE__);
        CollisionShape2TriangleMesh(collisionShape,startTrans,vertexPositions,vertexNormals,indices);
        gfxVertices.resize(vertexPositions.size());
        for (int i=0;i<vertexPositions.size();i++)
        {
            for (int j=0;j<4;j++)
            {
                gfxVertices[i].xyzw[j] = vertexPositions[i][j];
            }
            for (int j=0;j<3;j++)
            {
                gfxVertices[i].normal[j] = vertexNormals[i][j];
            }
            for (int j=0;j<2;j++)
            {
                gfxVertices[i].uv[j] = 0.5;//we don't have UV info...
            }
        }
    }
    
    if (gfxVertices.size() && indices.size())
    {
        int shapeId = registerGraphicsShape(&gfxVertices[0].xyzw[0],gfxVertices.size(),&indices[0],indices.size(),B3_GL_TRIANGLES,-1);
        collisionShape->setUserIndex(shapeId);
    }
    
}

int registerGraphicsShape(const float* vertices,
                          int numvertices,
                          const int* indices,
                          int numIndices,
                          int primitiveType,
                          int textureId)
{
    printf("TODO: bind vertices to shader\n");
    return 0;
}


@end
