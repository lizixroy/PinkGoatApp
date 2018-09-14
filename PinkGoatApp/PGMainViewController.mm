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

@interface PGMainViewController ()

@end

@implementation PGMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewDidAppear {
    [super viewDidAppear];
}

// TODO: move this to model layer.
- (void)importRobotModel {
    BulletURDFImporter u2b(NULL,0,1,0);
    bool loadOk = u2b.loadURDF("kuka_iiwa/model.urdf");// lwr / kuka.urdf");
    if (loadOk)
    {
        int rootLinkIndex = u2b.getRootLinkIndex();
        
        // TODO: How does p3Printf differ from printf?
        
//        b3Printf("urdf root link index = %d\n",rootLinkIndex);
        
        // TODO: need to port the MultiBodyCreator class
        MyMultiBodyCreator creation(m_guiHelper);
        btTransform identityTrans;
        identityTrans.setIdentity();
        ConvertURDF2Bullet(u2b, creation, identityTrans,m_dynamicsWorld,true,u2b.getPathPrefix());
        for (int i = 0; i < u2b.getNumAllocatedCollisionShapes(); i++)
        {
            m_collisionShapes.push_back(u2b.getAllocatedCollisionShape(i));
        }
        m_multiBody = creation.getBulletMultiBody();
        if (m_multiBody)
        {
            //kuka without joint control/constraints will gain energy explode soon due to timestep/integrator
            //temporarily set some extreme damping factors until we have some joint control or constraints
            m_multiBody->setAngularDamping(0*0.99);
            m_multiBody->setLinearDamping(0*0.99);
            b3Printf("Root link name = %s",u2b.getLinkName(u2b.getRootLinkIndex()).c_str());
        }
    }

}

@end
