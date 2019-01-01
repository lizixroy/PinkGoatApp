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

- (void)setupWithAngles:(NSMutableArray<NSNumber *> *)jointAngles
{
    _jointAngles = jointAngles;
    _lines = [[NSMutableArray alloc] init];
    NSArray *colors = [self makeColorsForNumberOfLines:_lines.count];
    for (int i = 0; i < jointAngles.count; i++) {
        _lineBufferSize = self.frame.size.width;
        NSColor *color = colors[i];
        PGTimeSeriesLine *line = [[PGTimeSeriesLine alloc] initWithBufferSize:self.lineBufferSize color:color];
        [_lines addObject:line];
    }
    self.wantsLayer = YES;
    self.layer.backgroundColor = NSColor.whiteColor.CGColor;
}

- (instancetype)initWithFrame:(NSRect)frameRect
                  jointAngles:(NSMutableArray<NSNumber *> *)jointAngles;
{
    self = [super initWithFrame:frameRect];
    if (self) {
        [self setupWithAngles:jointAngles];
        
    }
    return self;
}

- (void)update
{
    for (int i = 0; i < self.jointAngles.count; i++) {
        NSNumber *angle = self.jointAngles[i];
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

- (NSArray<NSColor *> *)makeColorsForNumberOfLines:(NSUInteger)numerOfLines
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:[NSColor colorWithDeviceRed:0.7412 green:0.2118 blue:0.1569 alpha:1.0]]; // red
    [array addObject:[NSColor colorWithDeviceRed:0.8353 green:0.5373 blue:0.2353 alpha:1.0]]; // orange
    [array addObject:[NSColor colorWithDeviceRed:0.9529 green:1.0000 blue:0.3686 alpha:1.0]]; // yellow
    [array addObject:[NSColor colorWithDeviceRed:0.6275 green:0.9059 blue:0.6784 alpha:1.0]]; // green
    [array addObject:[NSColor colorWithDeviceRed:0.3412 green:0.5725 blue:0.8706 alpha:1.0]]; // blue
    [array addObject:[NSColor colorWithDeviceRed:0.3725 green:0.0824 blue:0.8980 alpha:1.0]]; // indigo
    [array addObject:[NSColor colorWithDeviceRed:0.4706 green:0.1804 blue:0.9020 alpha:1.0]]; // purple
    // Generate random colors for the remaining.
    
    if (numerOfLines > array.count) {
        NSUInteger n = numerOfLines - array.count;
        for (int i = 0; i < n; i++) {
            [array addObject:[self generateRandomColor]];
        }
    }
    return [NSArray arrayWithArray:array];
}

- (NSColor *)generateRandomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    NSColor *color = [NSColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return color;
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
