//
//  Gripper.h
//  PinkGoatApp
//
//  Created by Roy Li on 3/4/19.
//  Copyright © 2019 Roy Li. All rights reserved.
//

#import "PGRobot.h"

NS_ASSUME_NONNULL_BEGIN

@interface Gripper : PGRobot

- (void)close;
- (void)open;

@end

NS_ASSUME_NONNULL_END
