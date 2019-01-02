//
//  PGTimeSeriesView.m
//  GraphTest
//
//  Created by Roy Li on 12/30/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGTimeSeriesView.h"
#import <CoreGraphics/CoreGraphics.h>
#import <CoreText/CoreText.h>
#import <math.h>
#import "PGTimeSeriesLine.h"

// padding on top and bottomso that the lines won't go to the edge of the view and be clipped in a strange way.
static CGFloat PADDING = 10.0f;

@interface PGTimeSeriesView()

@property (nonatomic, strong) NSMutableArray<PGTimeSeriesLine *> *lines;
@property (nonatomic, assign) CGFloat lineBufferSize;

@end

@implementation PGTimeSeriesView

- (void)setupWithJointCount:(NSUInteger)jointCount lineColors:(NSArray<NSColor *> *)colors
{
    _jointAngles = [[NSMutableArray alloc] init];
    _lines = [[NSMutableArray alloc] init];
    for (int i = 0; i < jointCount; i++) {
        _lineBufferSize = self.frame.size.width;
        NSColor *color = colors[i];
        PGTimeSeriesLine *line = [[PGTimeSeriesLine alloc] initWithBufferSize:self.lineBufferSize color:color];
        [_lines addObject:line];
        // insert default value 0 into joint angles array.
        [_jointAngles addObject:@0];
    }
    self.wantsLayer = YES;
    self.layer.backgroundColor = NSColor.whiteColor.CGColor;
}

- (void)updateWithJointVariables:(NSArray<NSNumber *> *)jointVariables
{
    for (int i = 0; i < jointVariables.count; i++) {
        NSNumber *angle = jointVariables[i];
        PGTimeSeriesLine *line = [self.lines objectAtIndex:i];
        [line insertValue:angle];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // Drawing code here.
    for (PGTimeSeriesLine *line in self.lines) {
        [self drawLine:line];
    }
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    [self drawHorizonTalDashLineWithContext:context];
}

- (void)drawLine:(PGTimeSeriesLine *)line
{
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    while (line.values.count < self.lineBufferSize) {
        // pad values array with 0
        [line.values insertObject:@0 atIndex:0];
    }
    CGFloat x = 0;
    for (int i = 0; i < line.values.count; i++) {
        CGFloat angle = line.values[i].floatValue;
        CGFloat y = [self getYCoordinateForAngle:angle];
        if (i == 0) {
            CGContextMoveToPoint(context, x, y);
        } else {
            CGContextAddLineToPoint(context, x, y);
        }
        x++;
    }
    
    CGContextSetStrokeColorWithColor(context, line.color.CGColor);
    CGContextSetLineWidth(context, 2);
    CGContextDrawPath(context, kCGPathStroke);
}

/**
 Calcuate the y coordinate for a point, given the angle specified in radians.

 @param angle in radians
 @return y cooridnate
 */
- (CGFloat)getYCoordinateForAngle:(CGFloat)angle
{
    CGFloat midY = self.frame.size.height / 2;
    if (angle == 0) {
        return midY;
    }
    CGFloat height = self.frame.size.height / 2 - PADDING;
    if (angle > 0) {
        CGFloat h = (angle * height) / M_PI;
        return midY + h;
    } else {
        CGFloat h = (angle * height) / M_PI;
        return midY - fabs(h);
    }
}

- (void)drawHorizonTalDashLineWithContext:(CGContextRef)context
{
    CGContextSetStrokeColorWithColor(context, NSColor.lightGrayColor.CGColor);
    CGFloat startX = 0;
    CGFloat endX = self.frame.size.width;
    CGFloat y = self.frame.size.height / 2;
    CGFloat dashes[] = { 5, 3 };
    CGContextSetLineDash( context, 3.0, dashes, 2 );
    CGContextMoveToPoint(context, startX, y);
    CGContextAddLineToPoint(context, endX, y);
    CGContextSetLineWidth(context, 1);
    CGContextDrawPath(context, kCGPathStroke);
}

@end
