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
#import "PGVertexObject.h"
#import <simd/simd.h>

enum
{
    B3_GL_TRIANGLES = 1,
    B3_GL_POINTS
};

@implementation PGVertexFactory

- (void)makeVerticesFromCollisionObject:(btCollisionObject *)collisionObject
                                                                 vertices:(btAlignedObjectArray<GLInstanceVertex>&)vertices indices:(btAlignedObjectArray<int>&)indices;
{
    createCollisionShapeGraphicsObject(collisionObject->getCollisionShape(), vertices, indices);
}

- (PGShape *)makeShapeFromCollisionObject:(btCollisionObject *)collisionObject
                             localToWorld:(btTransform *)localToWorld;
{
    
    btTransform startTrans;startTrans.setIdentity();
    btAlignedObjectArray<btVector3> vertexPositions;
    btAlignedObjectArray<btVector3> vertexNormals;
    btAlignedObjectArray<int> indices;
    btAlignedObjectArray<GLInstanceVertex> gfxVertices;
    
    printf("<%s %d> Getting vertex positions, normals and indices\n", __FILE__, __LINE__);
    CollisionShape2TriangleMesh(collisionObject->getCollisionShape(),startTrans,vertexPositions,vertexNormals,indices);
    gfxVertices.resize(vertexPositions.size());
    
    NSMutableArray<PGVertexObject *> *vertices = [[NSMutableArray alloc] init];
    NSMutableArray<NSNumber *> *newIndices = [[NSMutableArray alloc] init];
    
    for (int i=0;i<vertexPositions.size();i++)
    {
        btVector3 position = vertexPositions[i];
        vector_float3 p;
        p.x = position.getX();
        p.y = position.getY();
        p.z = position.getZ();
        
        btVector3 normal = vertexNormals[i];
        vector_float3 n;
        n.x = normal.getX();
        n.y = normal.getY();
        n.z = normal.getZ();
        
        vector_float4 color = { 1, 1, 1, 1 }; // use default color for now.
        PGVertexObject *vertex = [[PGVertexObject alloc] initWithPosition:p normal:n color:color];
        [vertices addObject:vertex];
        
        int index = indices[i];
        [newIndices addObject:[NSNumber numberWithInt:index]];
    }
    PGShape *shape = [[PGShape alloc] initWithVertices:[NSArray arrayWithArray:vertices]
                                               indices:[NSArray arrayWithArray:newIndices]];
    shape.localToWorld = [self getMatrixFromTransfrom:*localToWorld];
    return shape;
}

- (matrix_float4x4)getMatrixFromTransfrom:(btTransform)transform
{
    btMatrix3x3 basis = transform.getBasis();
    btVector3 origin = transform.getOrigin();
    
    vector_float4 column0 = { basis.getColumn(0).getX(), basis.getColumn(0).getY(), basis.getColumn(0).getZ(), 0 };
    vector_float4 column1 = { basis.getColumn(1).getX(), basis.getColumn(1).getY(), basis.getColumn(1).getZ(), 0 };
    vector_float4 column2 = { basis.getColumn(2).getX(), basis.getColumn(2).getY(), basis.getColumn(2).getZ(), 0 };
    vector_float4 column3 = { origin.getX(), origin.getY(), origin.getZ(), 1 };
    matrix_float4x4 matrix = { column0, column1, column2, column3 };
    return matrix;
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
