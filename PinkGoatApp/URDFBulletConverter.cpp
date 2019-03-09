//
//  URDFBulletConverter.cpp
//  PinkGoatApp
//
//  Created by Roy Li on 9/4/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//


#include "URDFBulletConverter.h"

btMultiBody*
ModelFileBulletConverter::createMultiBodyFromSDFFile(const std::string &filePath)
{
    bool success = m_urdfImporter.loadSDF(filePath.c_str());
    if (!success) {
        return nullptr;
    }
    
    ModelFileToBulletConverterCache cache = ModelFileToBulletConverterCache(m_urdfImporter);
    int rootLinkIndex = m_urdfImporter.getRootLinkIndex();
    
    // TODO: move the following code into a helper method so it can be used by createMultiBodyFromURDFFile
    // the following will be done recursively in a separate function
    btTransform linkTransformInWorldSpace;
    linkTransformInWorldSpace.setIdentity();
    
//    int mbLinkIndex = cache.getMultiBodyIndexFromModelFileIndex(<#int modelFileIndex#>)
    
    // TODO: return the real thing.
    return nullptr;
}

// what should be the return value this method without modifying its variables?
void ModelFileBulletConverter::convertModelFileToBullet(int linkIndex,
                                                   const ModelFileToBulletConverterCache& cache,
                                                   int flags)
{
    btTransform linkTransformInWorldSpace;
    linkTransformInWorldSpace.setIdentity();
    
    int multiBodyLinkIndex = cache.getMultiBodyIndexFromModelFileIndex(linkIndex);
    int modelFileParentIndex = cache.getParentModelFileIndex(linkIndex);
    int multiBodyParentIndex = cache.getMultiBodyIndexFromModelFileIndex(modelFileParentIndex);
    
    btRigidBody* parentRigidBody = nullptr;
    btTransform parentLocalInertialFrame;
    parentLocalInertialFrame.setIdentity();
    btScalar parentMass(1);
    btVector3 parentLocalInertiaDiagonal(1,1,1);
    
    if (modelFileParentIndex != -2)
    {
        parentRigidBody = cache.getRigidBodyForLinkIndex(modelFileParentIndex);
        m_urdfImporter.getMassAndInertia2(modelFileParentIndex,
                                          parentMass,
                                          parentLocalInertiaDiagonal,
                                          parentLocalInertialFrame,
                                          flags);
    }
    
    btScalar mass = 0;
    btTransform localInertialFrame;
    localInertialFrame.setIdentity();
    btVector3 localInertiaDiagnonal(0,0,0);
    m_urdfImporter.getMassAndInertia2(linkIndex,
                                      mass,
                                      parentLocalInertiaDiagonal,
                                      localInertialFrame,
                                      flags);
    
    btTransform parentToJoint;
    parentToJoint.setIdentity();
    int jointType;
    
    
    
}

