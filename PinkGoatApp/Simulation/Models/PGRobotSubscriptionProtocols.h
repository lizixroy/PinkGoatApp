//
//  PGRobotSubscriptionProtocols.h
//  PinkGoatApp
//
//  Created by Roy Li on 12/31/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#ifndef PGRobotSubscriptionProtocols_h
#define PGRobotSubscriptionProtocols_h

@protocol PGRobotJointVariablesSubscriber

- (void)updateWithJointVariables:(NSArray <NSNumber *> *)jointVariables;

@end

#endif /* PGRobotSubscriptionProtocols_h */
