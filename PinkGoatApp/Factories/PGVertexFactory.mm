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

- (void)makeVerticesFromCollisionObject:(btCollisionObject *)collisionObject
                                                                 vertices:(btAlignedObjectArray<GLInstanceVertex>&)vertices indices:(btAlignedObjectArray<int>&)indices;
{
//    btAlignedObjectArray<GLInstanceVertex> gfxVertices;
//    btAlignedObjectArray<int> indices;
    createCollisionShapeGraphicsObject(collisionObject->getCollisionShape(), vertices, indices);
}

void createCollisionShapeGraphicsObject(btCollisionShape* collisionShape,
                                        btAlignedObjectArray<GLInstanceVertex>& gfxVertices,
                                        btAlignedObjectArray<int>& indices)
{
//    btAlignedObjectArray<GLInstanceVertex> gfxVertices;
//    btAlignedObjectArray<int> indices;
    
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
