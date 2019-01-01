//
//  PGTimeSeriesView.h
//  GraphTest
//
//  Created by Roy Li on 12/30/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGTimeSeriesView : NSView

@property (nonatomic, strong) NSMutableArray<NSNumber *> *jointAngles;

- (void)setupWithJointCount:(NSUInteger)jointCount;
- (void)updateWithJointVariables:(NSArray<NSNumber *> *)jointVariables;

@end

NS_ASSUME_NONNULL_END
