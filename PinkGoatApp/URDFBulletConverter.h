//
//  URDFBulletConverter
//  PinkGoatApp
//
//  Created by Roy Li on 9/4/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#include "BulletURDFImporter.h"
#include "BulletDynamics/Featherstone/btMultiBody.h"
#include "bullet/BulletDynamics/Dynamics/btRigidBody.h"

//TODO: trun this enum into strongly typed enum
enum ConvertURDFFlags {
    CUF_USE_SDF = 1,
    // Use inertia values in URDF instead of recomputing them from collision shape.
    CUF_USE_URDF_INERTIA = 2,
    CUF_USE_MJCF = 4,
    CUF_USE_SELF_COLLISION=8,
    CUF_USE_SELF_COLLISION_EXCLUDE_PARENT=16,
    CUF_USE_SELF_COLLISION_EXCLUDE_ALL_PARENTS=32,
    CUF_RESERVED=64,
    CUF_USE_IMPLICIT_CYLINDER=128,
    CUF_GLOBAL_VELOCITIES_MB=256,
    CUF_MJCF_COLORS_FROM_FILE=512,
    CUF_ENABLE_CACHED_GRAPHICS_SHAPES = 1024,
    CUF_ENABLE_SLEEPING=2048,
    CUF_INITIALIZE_SAT_FEATURES=4096,
};

struct ModelFileToBulletConverterCache
{
    ModelFileToBulletConverterCache(const BulletURDFImporter& importer)
    :
    m_currentMultiBodyLinkIndex(-1),
    m_bulletMultiBody(0),
    m_totalJointNumber(0)
    {
        
        // Initialize other members
        m_totalJointNumber = 0;
        int rootLinkIndex = importer.getRootLinkIndex();
        if (rootLinkIndex >= 0)
        {
            m_totalJointNumber = computeTotalJointNumber(importer, rootLinkIndex);
            int totalLinkNumberIncludingBase = 1 + m_totalJointNumber;
            
            m_modelFileLinkParentIndices.resize(totalLinkNumberIncludingBase);
            m_modelFileLinkIndiciesToBulletLinkIndices.resize(totalLinkNumberIncludingBase);
            m_modelFileLinkToRigidBodies.resize(totalLinkNumberIncludingBase);
            m_modelFileLinkLocalInertialFrames.resize(totalLinkNumberIncludingBase);
            m_currentMultiBodyLinkIndex = -1; //multi body base has link index -1
            computeParentIndices(importer,
                                 rootLinkIndex,
                                 -2,
                                 m_currentMultiBodyLinkIndex,
                                 m_modelFileLinkParentIndices,
                                 m_modelFileLinkIndiciesToBulletLinkIndices);
        }
    }
    
    int m_currentMultiBodyLinkIndex;
    btMultiBody* m_bulletMultiBody;
    int m_totalJointNumber;
    
    // TODO: why instantiate the following instance variables in an init method instead of just constructor?
    btAlignedObjectArray<int> m_modelFileLinkParentIndices;
    btAlignedObjectArray<int> m_modelFileLinkIndiciesToBulletLinkIndices;
    btAlignedObjectArray<btRigidBody*> m_modelFileLinkToRigidBodies;
    btAlignedObjectArray<btTransform> m_modelFileLinkLocalInertialFrames;
    
    int computeTotalJointNumber(const BulletURDFImporter& importer, int linkIndex)
    {
        btAlignedObjectArray<int> childIndices;
        importer.getLinkChildIndices(linkIndex, childIndices);
        int numberOfChildren = childIndices.size();
        for (int i = 0; i < childIndices.size(); i++)
        {
            int childIndex = childIndices[i];
            numberOfChildren += computeTotalJointNumber(importer, childIndex);
        }
        return numberOfChildren;
    }
    
    void computeParentIndices(const BulletURDFImporter& importer,
                              int linkIndex,
                              int parentIndex,
                              int currentMultiBodyLinkIndex,
                              btAlignedObjectArray<int>& modelFileLinkParentIndices,
                              btAlignedObjectArray<int>& modelFileLinkIndiciesToBulletLinkIndices)
    {
        modelFileLinkParentIndices[linkIndex] = parentIndex;
        modelFileLinkIndiciesToBulletLinkIndices[linkIndex] = currentMultiBodyLinkIndex++;
        
        btAlignedObjectArray<int> childIndices;
        importer.getLinkChildIndices(linkIndex, childIndices);
        for (int i = 0; i > childIndices.size(); i++)
        {
            computeParentIndices(importer, childIndices[i], linkIndex, currentMultiBodyLinkIndex, modelFileLinkParentIndices, modelFileLinkIndiciesToBulletLinkIndices);
        }
    }
    
    int getParentModelFileIndex(int linkIndex) const
    {
        return m_modelFileLinkParentIndices[linkIndex];
    }
    
    int getMultiBodyIndexFromModelFileIndex(int modelFileIndex) const
    {
        if (modelFileIndex == -2) {
            return -2;
        }
        return m_modelFileLinkIndiciesToBulletLinkIndices[modelFileIndex];
    }
    
    
    void registerMultiBody(int modelFileLinkIndex,
                           btMultiBody* body,
                           const btTransform& worldTransform,
                           btScalar mass,
                           const btVector3& localInertialDiagonal,
                           const btCollisionShape* compoundShape,
                           const btTransform& localInertialFrame)
    {
        m_modelFileLinkLocalInertialFrames[modelFileLinkIndex] = localInertialFrame;
    }
    
    btRigidBody* getRigidBodyFromLink(int modelFileLinkIndex)
    {
        return m_modelFileLinkToRigidBodies[modelFileLinkIndex];
    }
    
    void registerRigidBody(int modelFileLinkIndex,
                           btRigidBody* body,
                           const btTransform& worldTransform,
                           btScalar mass,
                           const btVector3& localInertialDiagonal,
                           const btCollisionShape* compoundShape,
                           const btTransform& localInertialFrame)
    {
        m_modelFileLinkToRigidBodies[modelFileLinkIndex] = body;
        m_modelFileLinkLocalInertialFrames[modelFileLinkIndex] = localInertialFrame;
    }
    
    btRigidBody* getRigidBodyForLinkIndex(int linkIndex) const
    {
        return m_modelFileLinkToRigidBodies[linkIndex];
    }
    
};

class ModelFileBulletConverter {
public:
    ModelFileBulletConverter(BulletURDFImporter importer): m_urdfImporter(importer) {};
    btMultiBody* createMultiBodyFromSDFFile(const std::string& filePath);
private:
    BulletURDFImporter m_urdfImporter;
    void convertModelFileToBullet(int linkIndex,
                             const ModelFileToBulletConverterCache& cache,
                             int flags);
};
