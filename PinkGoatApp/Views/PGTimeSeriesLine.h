//
//  PGTimeSeriesLine.h
//  GraphTest
//
//  Created by Roy Li on 12/30/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGTimeSeriesLine : NSObject

@property (nonatomic, strong) NSColor *color;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *values;

- (instancetype)initWithBufferSize:(size_t)bufferSize
                             color:(NSColor *)color;

/**
 Insert new point into line, if the bufferSize is reached, the first element will be remove when appending new point in the end.

 @param value new value to append in the end
 */
- (void)insertValue:(NSNumber *)value;

@end

NS_ASSUME_NONNULL_END
