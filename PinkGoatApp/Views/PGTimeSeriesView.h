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

/**
 Instantiate new time series view with jiont angles expressed in radians

 @param frameRect frame
 @param jointAngles angles in radians
 */
- (instancetype)initWithFrame:(NSRect)frameRect jointAngles:(NSMutableArray<NSNumber *> *)jointAngles;
- (void)setupWithAngles:(NSMutableArray<NSNumber *> *)jointAngles;
- (void)update;

@end

NS_ASSUME_NONNULL_END
