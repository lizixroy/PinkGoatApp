//
//  PGTimeSeriesViewController.h
//  PinkGoatApp
//
//  Created by Roy Li on 12/31/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGTimeSeriesViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>

- (void)setupWithJointVariables:(NSMutableArray<NSNumber *> *)jointVariables;

@end

NS_ASSUME_NONNULL_END
