//
//  PGTimeSeriesViewController.h
//  PinkGoatApp
//
//  Created by Roy Li on 12/31/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PGRobotSubscriptionProtocols.h"
#import "PGRobot.h"

NS_ASSUME_NONNULL_BEGIN

@interface PGTimeSeriesViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource, PGRobotJointVariablesSubscriber>

@property (weak) PGRobot *robot;

- (void)setupWithJointCount:(NSUInteger)jointCount robot:(PGRobot *)robot;

@end

NS_ASSUME_NONNULL_END
