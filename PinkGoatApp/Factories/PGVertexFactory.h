//
//  PGVertexFactory.h
//  PinkGoatApp
//
//  Created by Roy Li on 9/29/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../bullet/BulletCollision/CollisionDispatch/btCollisionObject.h"
#import "../bullet/BulletCollision/CollisionShapes/btCollisionShape.h"

struct GLInstanceVertex
{
    float xyzw[4];
    float normal[3];
    float uv[2];
};

struct MyHashShape
{
    
    int m_shapeKey;
    int m_shapeType;
    btVector3 m_sphere0Pos;
    btVector3 m_sphere1Pos;
    btScalar m_radius0;
    btScalar m_radius1;
    btTransform m_childTransform;
    int m_deformFunc;
    int m_upAxis;
    btScalar m_halfHeight;
    
    MyHashShape()
    :m_shapeKey(0),
    m_shapeType(0),
    m_sphere0Pos(btVector3(0,0,0)),
    m_sphere1Pos(btVector3(0,0,0)),
    m_radius0(0),
    m_radius1(0),
    m_deformFunc(0),
    m_upAxis(-1),
    m_halfHeight(0)
    {
        m_childTransform.setIdentity();
    }
    
    bool equals(const MyHashShape& other) const
    {
        bool sameShapeType = m_shapeType==other.m_shapeType;
        bool sameSphere0= m_sphere0Pos == other.m_sphere0Pos;
        bool sameSphere1= m_sphere1Pos == other.m_sphere1Pos;
        bool sameRadius0 = m_radius0== other.m_radius0;
        bool sameRadius1 = m_radius1== other.m_radius1;
        bool sameTransform = m_childTransform== other.m_childTransform;
        bool sameUpAxis = m_upAxis == other.m_upAxis;
        bool sameHalfHeight = m_halfHeight == other.m_halfHeight;
        return sameShapeType && sameSphere0 && sameSphere1 && sameRadius0 && sameRadius1 && sameTransform && sameUpAxis && sameHalfHeight;
    }
    //to our success
    SIMD_FORCE_INLINE    unsigned int getHash()const
    {
        unsigned int key = m_shapeKey;
        // Thomas Wang's hash
        key += ~(key << 15);    key ^=  (key >> 10);    key +=  (key << 3);    key ^=  (key >> 6);    key += ~(key << 11);    key ^=  (key >> 16);
        
        return key;
    }
};

@interface PGVertexFactory : NSObject

- (GLInstanceVertex *)makeVertexFromCollisionObject:(btCollisionObject *)collisionObject;

@end
