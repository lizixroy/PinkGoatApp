//
//  PGTimeSeriesLine.m
//  GraphTest
//
//  Created by Roy Li on 12/30/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGTimeSeriesLine.h"

@interface PGTimeSeriesLine()

// How many points to we store in the line.
@property (nonatomic, assign) size_t bufferSize;

@end

@implementation PGTimeSeriesLine

- (instancetype)initWithBufferSize:(size_t)bufferSize
                             color:(NSColor *)color
{
    self = [super init];
    if (self) {
        _bufferSize = bufferSize;
        _values = [[NSMutableArray alloc] init];
        _color = color;
    }
    return self;
}

- (void)insertValue:(NSNumber *)value;
{
    if (self.values.count == _bufferSize) {
        [self.values removeObjectAtIndex:0];
    }
    [self.values addObject:value];
}

@end
