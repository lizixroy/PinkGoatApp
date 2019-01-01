//
//  PGTimeSeriesViewController.h
//  PinkGoatApp
//
//  Created by Roy Li on 12/31/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PGRobotSubscriptionProtocols.h"

NS_ASSUME_NONNULL_BEGIN

@interface PGTimeSeriesViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource, PGRobotJointVariablesSubscriber>

- (void)setupWithJointCount:(NSUInteger)jointCount;

@end

NS_ASSUME_NONNULL_END
