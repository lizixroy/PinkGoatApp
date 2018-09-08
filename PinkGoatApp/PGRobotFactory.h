//
//  PGRobotFactory.h
//  PinkGoatApp
//
//  Created by Roy Li on 9/4/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGRobotFactory : NSObject

// Create SceneKit object backed by Bullet MultiBody from URDF.
- (void)createRobotModelFromURDF;

@end
