//
//  JointMotor.h
//  PinkGoatApp
//
//  Created by Roy Li on 3/5/19.
//  Copyright © 2019 Roy Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BulletDynamics/Featherstone/btMultiBodyJointMotor.h"

NS_ASSUME_NONNULL_BEGIN

@interface JointMotor : NSObject
{
    @public
    btMultiBodyJointMotor *motor;
}

@end

NS_ASSUME_NONNULL_END
