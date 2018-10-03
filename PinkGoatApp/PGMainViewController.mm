//
//  PGMainViewController.m
//  PinkGoatApp
//
//  Created by Roy Li on 9/4/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGMainViewController.h"
#import "BTMultiBodyDynamicsWorldWrapper.h"
#import "URDF2Bullet.h"
#import "BulletUrdfImporter.h"
#import "MyMultiBodyCreator.h"
#include "BulletDynamics/Featherstone/btMultiBodyDynamicsWorld.h"
#include "BulletDynamics/Featherstone/btMultiBody.h"
#import "BulletDynamics/Featherstone/btMultiBodyConstraintSolver.h"
#include "btDefaultCollisionConfiguration.h"
#import "bullet/BulletCollision/CollisionDispatch/btCollisionDispatcher.h"
#import "bullet/BulletCollision/CollisionDispatch/btCollisionObject.h"
#import "bullet/BulletCollision/BroadphaseCollision/btOverlappingPairCache.h"
#import "bullet/BulletCollision/BroadphaseCollision/btDbvtBroadphase.h"
#import "PGVertexFactory.h"

#import <SceneKit/SceneKit.h>
#import <SceneKit/ModelIO.h>

@interface PGMainViewController () {
    btMultiBodyDynamicsWorld* m_dynamicsWorld;
    btMultiBody* m_multiBody;
    btAlignedObjectArray<btCollisionShape*>    m_collisionShapes;
    btDefaultCollisionConfiguration* m_collisionConfiguration;
    btCollisionDispatcher*    m_dispatcher;
    btOverlappingPairCache* m_pairCache;
    btBroadphaseInterface*    m_broadphase;
    btMultiBodyConstraintSolver*    m_solver;
}

@end

@implementation PGMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [self setupScene];
    [self importRobotModel];
}

- (void)setupScene
{
    SCNScene *scene = [[SCNScene alloc] init];
    
    // create and add a camera to the scene
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    [scene.rootNode addChildNode:cameraNode];
    
    // place the camera
    cameraNode.position = SCNVector3Make(0, 0, 15);
    
    // create and add a light to the scene
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.position = SCNVector3Make(0, 10, 10);
    [scene.rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [NSColor darkGrayColor];
    [scene.rootNode addChildNode:ambientLightNode];

    SCNView *scnView = (SCNView *)self.view;
    
    // set the scene to the view
    scnView.scene = scene;
    
    // allows the user to manipulate the camera
    scnView.allowsCameraControl = YES;
    
    // show statistics such as fps and timing information
    scnView.showsStatistics = YES;
    
    // configure the view
    scnView.backgroundColor = [NSColor blackColor];

}

// TODO: move this to model layer.
- (void)importRobotModel {
    
    [self createEmptyDynamicsWorld];
    
    BulletURDFImporter u2b(NULL,0,1,0);
    
    bool loadOk = u2b.loadURDF("/Users/royli/Documents/bullet3/data/kuka_iiwa/model.urdf");// lwr / kuka.urdf");
    if (loadOk)
    {
        int rootLinkIndex = u2b.getRootLinkIndex();
        MyMultiBodyCreator creation;
        btTransform identityTrans;
        identityTrans.setIdentity();
        
        ConvertURDF2Bullet(u2b, creation, identityTrans, m_dynamicsWorld, true,u2b.getPathPrefix());
        for (int i = 0; i < u2b.getNumAllocatedCollisionShapes(); i++)
        {
            m_collisionShapes.push_back(u2b.getAllocatedCollisionShape(i));
        }
        m_multiBody = creation.getBulletMultiBody();
        btCollisionObjectArray& collisionObjects = m_dynamicsWorld->getCollisionObjectArray();
        PGVertexFactory *vertexFactory = [[PGVertexFactory alloc] init];
        
        NSMutableArray *sceneNodes = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < collisionObjects.size(); i++) {
            btCollisionObject *object = collisionObjects[i];
            btAlignedObjectArray<GLInstanceVertex> vertices;
            btAlignedObjectArray<int> indices;
            [vertexFactory makeVerticesFromCollisionObject:object vertices:vertices indices:indices];
            NSLog(@"Create %d vertices from object: %p", vertices.size(), object);
            
            SCNNode *node = [self makeSceneFromVertices:vertices indices:indices];
            if (node != nil) {
                [sceneNodes addObject:node];
            }
        }

        NSLog(@"Loaded %lu nodes", sceneNodes.count);
        
        SCNView *scnView = (SCNView *)self.view;
        
        for (int i = 0; i < sceneNodes.count; i++) {
            SCNNode *node = sceneNodes[i];
            [scnView.scene.rootNode addChildNode:node];
            NSLog(@"node position: %f %f %f", node.position.x, node.position.y, node.position.z);
        }
    }
}

- (SCNNode *)makeSceneFromVertices:(btAlignedObjectArray<GLInstanceVertex>&)vertices
                            indices:(btAlignedObjectArray<int>&)indices
{
    SCNVector3 positions[vertices.size()];
    SCNVector3 normals[vertices.size()];
    
    for (int i = 0; i < vertices.size(); i++) {
        GLInstanceVertex vertex = vertices[i];
        SCNVector3 position = SCNVector3Make(vertex.xyzw[0], vertex.xyzw[1], vertex.xyzw[2]);
        SCNVector3 normal = SCNVector3Make(vertex.normal[0], vertex.normal[1], vertex.normal[2]);
        positions[i] = position;
        normals[i] = normal;
    }
    
    SCNGeometrySource *positionSource = [SCNGeometrySource geometrySourceWithVertices:positions count:vertices.size()];
    SCNGeometrySource *normalSource = [SCNGeometrySource geometrySourceWithVertices:normals count:vertices.size()];
    
    NSData *data = [NSData dataWithBytes:&indices[0]
                                  length:indices.size()];
    SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:data
                                                                primitiveType:SCNGeometryPrimitiveTypeTriangles
                                                               primitiveCount:indices.size()
                                                                bytesPerIndex:sizeof(int)];
    
    SCNGeometry *geometry = [SCNGeometry geometryWithSources:@[positionSource, normalSource] elements:@[element]];
    SCNNode *node = [SCNNode nodeWithGeometry:geometry];
    return node;
}

- (void)createEmptyDynamicsWorld
{
    ///collision configuration contains default setup for memory, collision setup
    m_collisionConfiguration = new btDefaultCollisionConfiguration();
    //m_collisionConfiguration->setConvexConvexMultipointIterations();
//    m_filterCallback = new MyOverlapFilterCallback2();
    
    ///use the default collision dispatcher. For parallel processing you can use a diffent dispatcher (see Extras/BulletMultiThreaded)
    m_dispatcher = new    btCollisionDispatcher(m_collisionConfiguration);
    
    m_pairCache = new btHashedOverlappingPairCache();
    
//    m_pairCache->setOverlapFilterCallback(m_filterCallback);
    
    m_broadphase = new btDbvtBroadphase(m_pairCache);//btSimpleBroadphase();
    
    m_solver = new btMultiBodyConstraintSolver;
    
    m_dynamicsWorld = new btMultiBodyDynamicsWorld(m_dispatcher, m_broadphase, m_solver, m_collisionConfiguration);
    
    m_dynamicsWorld->setGravity(btVector3(0, -10, 0));

}

@end
